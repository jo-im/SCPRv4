module PmpArticleImporter
  extend LogsAsTask::ClassMethods

  SOURCE    = "pmp"
  ENDPOINT  = "https://api.pmp.io/"
  TAG       = "marketplace"
  PROFILE   = "story"
  LIMIT     = 10

  PROFILES = {
    :image => "APMImage",
    :audio => "APMAudio"
  }

  class << self
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    def sync
      stories = pmp.root.query['urn:collectiondoc:query:docs']
        .where(tag: TAG, profile: PROFILE, limit: LIMIT)
        .retrieve.items

      log "#{stories.size} PMP stories found"

      added = []

      stories.reject { |s|
        RemoteArticle.exists?(source: SOURCE, article_id: s.guid)
      }.each do |story|

        # The PMP API is returning stories with an empty Publish timestamp,
        # so we need to protect against it.
        published  = begin
          Time.zone.parse!(story.published.to_s)
        rescue ArgumentError
          Time.zone.now
        end

        # Get the URL for this story
        url = story.alternate.first.href if story.alternate.present?

        cached_article = RemoteArticle.new(
          :source       => SOURCE,
          :article_id   => story.guid,
          :headline     => story.title,
          :teaser       => story.teaser,
          :published_at => published,
          :url          => url,
          :is_new       => true
        )

        if cached_article.save
          added.push cached_article
          log "Saved PMP Story #{story.guid} as " \
              "RemoteArticle ##{cached_article.id}"
        else
          log "Couldn't save PMP Story ##{story.id}"
        end
      end # each

      added
    end



    def import(remote_article, options={})
      klass = (options[:import_to_class] || "NewsStory").constantize

      pmp_story = pmp.root.query['urn:collectiondoc:query:docs']
        .where(guid: remote_article.article_id, profile: PROFILE)
        .retrieve

      return false if !pmp_story

      # Build the Article from the API response
      article = klass.new(
        :status         => klass.status_id(:draft),
        :headline       => pmp_story.title,
        :teaser         => pmp_story.teaser,
        :short_headline => pmp_story.title,
        :body           => pmp_story.contentencoded,
      )

      # Set the source
      if article.is_a?(NewsStory)
        # TODO: This is temporary, at some point we'll need to figure out
        # how to determine the "source" of an article from PMP.
        # Right now we're only pulling in Marketplace stories.
        article.source        = "marketplace"
        article.news_agency   = "Marketplace"
      end

      # Bylines
      name = pmp_story.byline
      if name.present?
        byline = ContentByline.new(name: name)
        article.bylines.push byline
      end

      # Related Link
      # Is "alternate" always going to be a usable link?
      # I guess we'll find out eventually.
      # For now it seems that it's used to point to the live article.
      link = pmp_story.alternate.first
      if link && link.href
        related_link = RelatedLink.new(
          :link_type    => "website",
          :title        => "View the original story",
          :url          => link.href
        )

        article.related_links.push related_link
      end

      if pmp_story.items.present?
        image = pmp_story.items.find do |i|
          i.profile.first.title == PROFILES[:image]
        end

        audio = pmp_story.items.find do |i|
          i.profile.first.title == PROFILES[:audio]
        end

        # If we have an enclosure node, extract audio and assets from it.
        # Import Audio
        if audio
          audios = Array(audio.enclosure)

          if !audios.empty?
            audios.each_with_index do |remote_audio, i|
              href    = remote_audio.href
              api_url = remote_audio.meta['api']['href']

              audio_data = open(api_url) { |r| JSON.parse(r.read) }

              # Podcast audio isn't always available. In this case we
              # should just not import any audio.
              if meta = audio_data[href]['podcast']
                # Using "title" for description here because the "description"
                # property seems to be an internal description, like:
                #
                #   "A 'show' containing all the individual segments for
                #   Marketplace to ship off to Slacker and other distributors"
                article.audio.build(
                  :url            => meta['http_file_path'],
                  :duration       => meta['duration'].to_i / 1000,
                  :description    => meta['title'],
                  :byline         => "APM",
                  :position       => i
                )
              end
            end
          end # audios
        end # audio

        # Import Primary Image
        # We're doing this last since it hits an external API... we don't
        # want the images to be uploaded and saved if the story isn't going
        # to be imported all the way (due to error).
        if image
          images = Array(image.enclosure)

          if !images.empty?
            # Get the image designated as "primary". If none exists,
            # then get the widest one.
            primary_image = images.find { |i| i.meta["crop"] == "primary" }
            primary_image ||= images.max do |a, b|
              a.meta["width"].to_i <=> b.meta["width"].to_i
            end

            if primary_image
              asset = AssetHost::Asset.create(
                :url     => primary_image.href,
                :title   => pmp_story.title,
                :owner   => "Marketplace",
                :note    => "Imported from PMP: #{pmp_story.guid}"
              )

              if asset && asset.id
                content_asset = ContentAsset.new(
                  :position   => 0,
                  :asset_id   => asset.id,
                  :caption => "" # To avoid 'doesn't have a default value' err
                )

                article.assets << content_asset
              end
            end # primary_image

          end # images
        end # image

      end # / pmp.items

      # Save the news story (including all associations),
      # set the RemoteArticle to `:is_new => false`,
      # and return the NewsStory that was generated.
      article.save!
      remote_article.update_attribute(:is_new, false)
      article
    end

    add_transaction_tracer :import, category: :task


    private

    # This isn't memoized so that we get a fresh API result each time.
    # Just be careful not to call this more than once in a method.
    def pmp
      config = Rails.configuration.x.api.pmp

      client = PMP::Client.new({
        :client_id        => config['client_id'],
        :client_secret    => config['client_secret'],
        :endpoint         => ENDPOINT
      })

      # Load the root document
      client.root.load
      client
    end
  end
end

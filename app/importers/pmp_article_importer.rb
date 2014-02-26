module PmpArticleImporter
  extend LogsAsTask::ClassMethods

  SOURCE    = "pmp"
  ENDPOINT  = "https://api-sandbox.pmp.io/"
  TAG       = "marketplace"
  PROFILE   = "story"
  LIMIT     = 10

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

        cached_article = RemoteArticle.new(
          :source       => SOURCE,
          :article_id   => story.guid,
          :headline     => story.title,
          :teaser       => story.teaser,
          :published_at => Time.parse(story.published),
          :url          => story.alternate.try(:href),
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
      link = pmp_story.alternate
      if link && link.href
        related_link = RelatedLink.new(
          :link_type    => "website",
          :title        => "View the original story",
          :url          => link.href
        )

        article.related_links.push related_link
      end

      if pmp_story.items.present?
        # If we have an enclosure node, extract audio and assets from it.
        # Sometimes it's an array and sometimes it's not.
        # We're using Array.wrap here because it doesn't work with just Array()
        enclosure = Array.wrap(pmp_story.items.first.enclosure)
        if !enclosure.empty?
          # Audio
          audio = enclosure.select do |e|
            e.type.match /audio/
          end

          audio.each_with_index do |remote_audio, i|
            url = remote_audio.href.gsub(
              "apm-audio:", "http://download.publicradio.org/podcast")

            article.audio.build(
              :url            => url,
              :description    => pmp_story.title,
              :byline         => "APM",
              :position       => i
            )
          end

          # Asset
          images = enclosure.select do |e|
            e.type.match(/image/)
          end

          # Get the image designated as "primary". If none exists,
          # then get the widest one.
          primary_image = images.find { |i| i.meta["crop"] == "primary" } ||
            images.max { |a, b| a.meta["width"].to_i <=> b.meta["width"].to_i }

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
                :asset_id   => asset.id
                :caption => "" # To avoid 'doesn't have a default value' err
              )

              article.assets << content_asset
            end
          end
        end # /enclosure
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

    def pmp
      @client ||= begin
        config = Rails.application.config.api['pmp']

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
end

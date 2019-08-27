module PmpArticleImporter
  extend LogsAsTask::ClassMethods

  SOURCE     = "pmp"
  ENDPOINT   = "https://api.pmp.io/"
  PROFILE    = "story"
  LIMIT      = 10

  PROFILES = {
    :image => ["APMImage", "Image Profile"],
    :audio => ["APMAudio", "Audio Profile"]
  }

  class << self
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    def sync
      stories = []

      ## Stories are downloaded in two ways: a query on a tag(marketplace) and from
      ## a collection that is specific to veteran stories.  Both sets of results are
      ## concatenated to the stories array.
      stories.concat download_stories("Marketplace", tag: "marketplace")
      stories.concat download_stories("American Homefront Project", text: '"American Homefront"')
      stories.concat download_stories("California Counts", tag: "CACounts", creator: "!aa9342f6-6e25-4ea2-93e3-31d89a010668") # stories that are not our own
      stories
    end

    def query query={}
      pmp.root.query['urn:collectiondoc:query:docs']
        .where({profile: PROFILE, limit: LIMIT}.merge(query))
        .retrieve.items
    end

    def download_stories news_agency_name, query={}
      added = []

      begin
        stories = query(query)
      rescue StandardError => err
        stories = []
      end

      log "#{stories.size} PMP stories from #{news_agency_name} found"
      stories.each do |story|

        if existing_article = RemoteArticle.where(source: SOURCE, article_id: story.guid).first
          new_url = if story.alternate.present? then story.alternate.first.href else existing_article.url end
          existing_article.update headline: story.title, teaser: story.teaser, url: new_url
          next
        end

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
          :source         => SOURCE,
          :article_id     => story.guid,
          :headline       => story.title,
          :teaser         => story.teaser,
          :published_at   => published,
          :url            => url,
          :is_new         => true,
          :news_agency      => news_agency_name
        )

        if cached_article.save
          added.push cached_article
          log "Saved PMP Story #{story.guid} as " \
              "RemoteArticle ##{cached_article.id}"
        else
          log "Couldn't save PMP Story ##{story.id}"
        end
      end
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
        news_agency = remote_article.news_agency || "PMP"

        article.source        = news_agency.downcase.gsub(" ", "_")
        article.news_agency   = news_agency
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
      link = (pmp_story.alternate || []).first
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
          PROFILES[:image].include? i.profile.first.title
        end

        audio = pmp_story.items.find do |i|
          PROFILES[:audio].include? i.profile.first.title
        end

        # Import Audio
        # If we have an enclosure node, extract audio and assets from it.
        #
        # Using "title" for description here because the "description"
        # property seems to be an internal description, like:
        #
        #   "A 'show' containing all the individual segments for
        #   Marketplace to ship off to Slacker and other distributors"
        if audio && !(audios = Array(audio.enclosure)).empty?
          audios.each_with_index do |remote_audio, i|
            audio_attributes = {byline: "APM", position: i}
            case article.news_agency
            when "Marketplace"
              api_url = remote_audio.meta['api']['href']
              audio_data = open(api_url) { |r| JSON.parse(r.read) }
              if meta = audio_data[audio_data.keys.first]['podcast']
                audio_attributes.merge!({
                  url:      meta['http_file_path'],
                  duration: meta['duration'].to_i / 1000,
                  description: meta['title']
                })
              end
            when "American Homefront Project"
              audio_attributes.merge!({
                url: remote_audio.href,
                # default to 0 if duration isn't given
                duration: (remote_audio.try(:meta).try(:duration).try(:to_i) || 0) / 1000,
                description: audio.title
              })
            end
            # Podcast audio isn't always available. In this case we
            # should just not import any audio.
            article.audio.build(audio_attributes) if audio_attributes[:url]
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
            thumbnail_image = images.find { |i| i.meta["crop"] == "small" }
            thumbnail_image ||= images.min do |a, b|
              a.meta["width"].to_i <=> b.meta["width"].to_i
            end

            if primary_image
              external_asset = {
                title: pmp_story.title,
                caption: "",
                owner: article.news_agency,
                urls: {
                  original: primary_image.href,
                  thumb: thumbnail_image.href
                }
              }.to_json

              # Create a content asset and store the external asset as a json string
              content_asset = ContentAsset.new(
                :position   => 0,
                :external_asset => external_asset,
                :caption    => ""
              )

              article.assets << content_asset
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
      config = Rails.configuration.x.api.pmp['read']

      client = PMP::Client.new({
        :client_id        => config['client_id'],
        :client_secret    => config['client_secret'],
        :endpoint         => ENDPOINT
      })

      # Load the root document
      client.root.retrieve
      client
    end
  end
end

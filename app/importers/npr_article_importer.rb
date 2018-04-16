module NprArticleImporter
  extend LogsAsTask::ClassMethods

  SOURCE = "npr"
  # NPR IDs we're importing:
  # Reference: http://www.npr.org/api/inputReference.php
  IMPORT_IDS = [
    '1001',      # News (topic)
    '1007',      # Science (topic)
    '311911180',  # NPR Ed (blog)
    '103537970',  # Shots (blog)
    '93568166',  # Monkey See (blog)
    '173754155',  # Code Switch (blog)
    '102920358'  # All Tech Considered (blog)
  ]


  class << self
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    def sync
      # The "id" parameter in this case is actually referencing a list.
      # Stories from the last hour are returned... be sure to run this script
      # more often than that!

      npr_stories = []
      offset      = 0
      start_date  = RemoteArticle.where(source: "npr").last.try(:published_at) || 1.hour.ago
      end_date    = Time.zone.now
      begin
        response  = fetch_stories(start_date, end_date, offset)
        npr_stories   += response
        offset    += 20
      end until response.size < 20

      log "#{npr_stories.size} NPR stories found since last import."

      added = []

      npr_stories.each do |npr_story|
        if existing_story = RemoteArticle.where(article_id: npr_story.id.to_s, source: SOURCE).first
          existing_story.update headline: npr_story.title, teaser: npr_story.teaser, url: npr_story.link_for("html")
          next
        end

        cached_article = RemoteArticle.new(
          :source       => SOURCE,
          :article_id   => npr_story.id,
          :headline     => npr_story.title,
          :teaser       => npr_story.teaser,
          :published_at => npr_story.pubDate,
          :url          => npr_story.link_for("html"),
          :is_new       => true
        )

        begin
          if cached_article.save
            added.push cached_article
            log "Saved NPR Story ##{npr_story.id} as " \
                "RemoteArticle ##{cached_article.id}"
          else
            log "Couldn't save NPR Story ##{npr_story.id}"
          end
        rescue ActiveRecord::RecordNotUnique
          log "NPR Story ##{npr_story.id} already exists"
        end

      end

      added
    end

    def fetch_stories start_date, end_date, offset
      NPR::Story.where(
          :id     => IMPORT_IDS,
          :date   => (start_date..end_date))
        .set(
          :requiredAssets   => 'text',
          :action           => "or")
        .order("date ascending").limit(20).offset(offset).to_a
    end


    def import(remote_article, options={})
      klass = (options[:import_to_class] || "NewsStory").constantize

      npr_story = NPR::Story.find_by_id(remote_article.article_id)
      return false if !npr_story

      text = begin
        if npr_story.textWithHtml.present?
          npr_story.textWithHtml.to_html
        elsif npr_story.text.present?
          npr_story.text.to_html
        end
      end

      #-------------------
      # Build the NewsStory from the API response
      article = klass.new(
        :status         => klass.status_id(:draft),
        :headline       => npr_story.title,
        :teaser         => npr_story.teaser,
        :short_headline => npr_story.shortTitle.present? ? npr_story.shortTitle : npr_story.title,
        :body           => text
      )

      if article.is_a? NewsStory
        article.news_agency   = "NPR"
        article.source        = "npr"
      end

      #-------------------
      # Add in Bylines
      npr_story.bylines.each do |npr_byline|
        name = npr_byline.name.to_s

        if name.present?
          byline = ContentByline.new(name: name)
          article.bylines.push byline
        end
      end


      #-------------------
      # Add a related link pointing to this story at NPR
      if link = npr_story.link_for('html')
        related_link = RelatedLink.new(
          :link_type => "website",
          :title     => "View this story at NPR",
          :url      => link
        )

        article.related_links.push related_link
      end

      # Bring in Audio
      npr_story.audio.select { |a| a.permissions.stream? }
      .each_with_index do |remote_audio, i|
        if mp3 = remote_audio.formats.mp3s.find { |m| m.type == "mp3" }
          article.audio.build(
            :url            => mp3.content,
            :duration       => remote_audio.duration,
            :description    => remote_audio.description ||
                               remote_audio.title ||
                               story.title,
            :byline         => remote_audio.rightsHolder || "NPR",
            :position       => i
          )
        end
      end


      #-------------------
      # Add in the primary asset if it exists
      if image = npr_story.primary_image
        # Try a few different crops to see which one is available.
        # We prefer the largest possible image with the least cropped out.
        crop =  image.enlargement ||
                image.crop("enlargment") ||
                image.crop("standard") ||
                image

        # # Temporarily silencing Asset creation during test period.
        # # This is so that we don't add assets unnecessarily as we explore the option of
        # # publishing NPR articles as they are received.
        #
        # asset = AssetHost::Asset.create(
        #   :url     => crop.src,
        #   :title   => image.title,
        #   :caption => image.caption,
        #   :owner   => [image.producer, image.provider].join("/"),
        #   :note    => "Imported from NPR: #{npr_story.link_for('html')}"
        # )
        #
        # if asset && asset.id
        #   content_asset = ContentAsset.new(
        #     :position   => 0,
        #     :asset_id   => asset.id,
        #     :caption    => image.caption
        #   )
        #
        #   article.assets << content_asset
        # end
      end


      #-------------------
      # Save the news story (including all associations),
      # set the RemoteArticle to `:is_new => false`,
      # and return the NewsStory that was generated.
      article.save!
      remote_article.update_attribute(:is_new, false)
      article
    end

    add_transaction_tracer :import, category: :task
  end
end

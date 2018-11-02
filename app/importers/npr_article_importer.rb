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

  # Basic map to match our categories with theirs
  CATEGORY_MAP = {
    "Art & Design" => "Arts & Entertainment",
    "Arts & Life" => "Arts & Entertainment",
    "Education" => "Education",
    "Environment" => "Environment & Science",
    "Health" => "Health",
    "Law" => "Crime & Justice",
    "National" => "US & World",
    "Politics" => "Politics",
    "Science" => "Science",
    "World" => "US & World"
  }

  REGEXP_EXCEPTIONS = [
    /exclusive\s+audio:/i,
    /top\s+stories:/i,
    /video:/i,
    /watch\s+live:/i,
    /watch:/i
  ]

  class << self
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    def elligible_for_autopublish? npr_story
      elligibility = true

      # iterate through our list of exceptions, and if a story contains any of them, mark it as inelligible
      REGEXP_EXCEPTIONS.each do |regex|
        if npr_story.title =~ regex
          elligibility = false
          break
        end
      end

      # mark the story as inelligible if it has any external assets (usually rich inline content)
      if npr_story.external_assets.any?
        elligibility = false
      end

      # mark the story as unsupported if it has more images than the primary image (usually inline images)
      if npr_story.images.length > 1
        elligibility = false
      end

      # check if another story with an identical slug was already recently autopublished
      slug = npr_story.title.parameterize[0...50].sub(/-+\z/, "")
      recent_stories_with_identical_slug = NewsStory
        .where('published_at > ?', DateTime.yesterday)
        .where(slug: slug)

      if recent_stories_with_identical_slug.present?
        elligibility = false
      end

      elligibility
    end

    def auto_publish remote_article, npr_story

      # A boolean to control whether autopublishing functionality should be on or off (0 #=> false, 1 #=> true)
      npr_auto_publish_on = DataPoint.find_by(data_key: "npr_auto_publish_on").try(:data_value).try(:to_i) || 1

      # Check that all conditions pass: auth-publish is on, the article is elligible, and the environment is either production or test
      if !npr_auto_publish_on.zero? && elligible_for_autopublish?(npr_story) && (Rails.env.production? || Rails.env.test?)
        self.import remote_article, { npr_story: npr_story, manual: false }
      else
        log "Skipping auto-import of story: #{npr_story.id}"
      end
    end

    def sync
      # The "id" parameter in this case is actually referencing a list.
      # Stories from the last hour are returned... be sure to run this script
      # more often than that!

      # We try to find if a delay was defined as a DataPoint, and if it is, convert it to an integer
      npr_auto_publish_delay = DataPoint.find_by(data_key: "npr_auto_publish_delay").try(:data_value).try(:to_i)

      # There needs to be a padding greater than the delay  (e.g. "3" hours)
      # so that articles published earlier than "2" hours ago can be found
      npr_auto_publish_padding = (npr_auto_publish_delay || 120) + 60

      npr_stories = []
      offset      = 0
      start_date  = npr_auto_publish_padding.try(:minutes).try(:ago) || 180.minutes.ago
      end_date    = Time.zone.now
      begin
        response  = fetch_stories(start_date, end_date, offset)
        npr_stories   += response
        offset    += 20
      end until response.size < 20

      log "#{npr_stories.size} NPR stories found since last import."

      added = []

      npr_stories.each do |npr_story|
        # Prepend [wont-autopublish] to the remote article's title if the story is inelligible
        if elligible_for_autopublish?(npr_story)
          remote_article_headline = npr_story.title
        else
          remote_article_headline = "[wont-autopublish] #{npr_story.title}"
        end

        if existing_story = RemoteArticle.where(article_id: npr_story.id.to_s, source: SOURCE).first
          existing_story.update headline: remote_article_headline, teaser: npr_story.teaser, url: npr_story.link_for("html")

          # If the current npr story was published earlier than our delay period
          if existing_story.published_at < (npr_auto_publish_delay || 120).minutes.ago && existing_story.is_new
            # begin the auto-publish process
            self.auto_publish(existing_story, npr_story)
          end

          next
        end

        cached_article = RemoteArticle.new(
          :source       => SOURCE,
          :article_id   => npr_story.id,
          :headline     => remote_article_headline,
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

      npr_story = options[:npr_story] || NPR::Story.find_by_id(remote_article.article_id)
      return false if !npr_story

      text = begin
        if npr_story.textWithHtml.present?
          npr_story.textWithHtml.to_html
        elsif npr_story.text.present?
          npr_story.text.to_html
        end
      end

      primary_topic = npr_story.parents.select{|parent| parent.type == 'primaryTopic'}.try(:first)
      primary_topic_title = primary_topic.try(:title)

      import_status = :live
      # If manually importing from the queue, set status to draft
      if options[:manual] === true
        import_status = :draft
      end

      #-------------------
      # Build the NewsStory from the API response
      article = klass.new(
        :status         => klass.status_id(import_status),
        :headline       => npr_story.title,
        :teaser         => npr_story.teaser,
        :short_headline => npr_story.shortTitle.present? ? npr_story.shortTitle : npr_story.title,
        :body           => text,
        :category_id    => Category.find_by(title: CATEGORY_MAP[primary_topic_title]).try(:id)
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

        asset = AssetHost::Asset.create(
          :url     => crop.src,
          :title   => image.title,
          :caption => image.caption,
          :owner   => [image.producer, image.provider].join("/"),
          :note    => "Imported from NPR: #{npr_story.link_for('html')}"
        )

        if asset && asset.id
          content_asset = ContentAsset.new(
            :position   => 0,
            :asset_id   => asset.id,
            :caption    => image.caption
          )

          article.assets << content_asset
        end
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

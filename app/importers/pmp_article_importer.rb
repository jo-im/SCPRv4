module PmpArticleImporter
  extend LogsAsTask::ClassMethods

  SOURCE = "pmp"
  ENDPOINT = "https://api-sandbox.pmp.io/"

  class << self
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    def sync
      stories = pmp.root.query['urn:collectiondoc:query:docs'].retrieve.items
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
          :url          => nil,
          :is_new       => true
        )

        if cached_article.save
          added.push cached_article
          log "Saved PMP Story ##{story.guid} as " \
              "RemoteArticle ##{cached_article.id}"
        else
          log "Couldn't save PMP Story ##{story.id}"
        end
      end # each

      added
    end



    def import(remote_article, options={})
      klass = (options[:import_to_class] || "NewsStory").constantize

      story = pmp.root.query['urn:collectiondoc:query:docs']
        .where(guid: remote_article.article_id)
        .retrieve.items.first

      return false if !story

      # Build the NewsStory from the API response
      article = klass.new(
        :status         => klass.status_id(:draft),
        :headline       => story.title,
        :teaser         => story.teaser,
        :short_headline => story.title,
        :body           => story.contentencoded # is this right?
      )

      if article.is_a? NewsStory
        article.news_agency   = ""
        article.source        = ""
      end

      # Bylines

      # Related Link

      # Audio

      # Asset?

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
          :client_secret    => config['client_secret']
          :endpoint         => ENDPOINT
        })

        # Load the root document
        client.root.load
        client
      end
    end
  end
end

# Import a remote article
module Job
  class ImportRemoteArticle < Base
    # This is high priority because an editor has to wait for the story
    # to import before he can continue to work.
    @priority = :high

    class << self
      def perform(id, import_to_class)
        @remote_article = RemoteArticle.find(id)
        @story = @remote_article.import(import_to_class: import_to_class, manual: true)

        # We want a failure to import to be caught by Resque.
        if !@story
          raise "The API didn't return anything."
        end
      end

      def on_failure(error)
        raise error
      end
    end
  end
end

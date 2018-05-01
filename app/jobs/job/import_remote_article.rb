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

      #---------------------

      def after_perform(id, import_to_class)
        hook = Newsroom::Client.new(
          :path => "/task/finished/#{@remote_article.obj_key}:import",
          :data => {
            :location         => @story.admin_edit_path,
            :notifications    => {
              :notice =>  "Successfully imported " \
                          "<strong>#{@remote_article.headline}</strong>"
            }
          }
        )

        # The current Newsroom server is very slow - retry the hook
        # a few times so the user will be redirected properly.
        timeout_retry(3) do
          hook.publish
        end
      end

      #---------------------

      def on_failure(error, id, import_to_class)
        hook = Newsroom::Client.new(
          :path => "/task/finished/#{@remote_article.obj_key}:import",
          :data => {
            :location         => RemoteArticle.admin_index_path,
            :notifications    => {
              :alert => \
                if @story
                  "The story was imported, but another error occurred. " \
                  "(#{error.message})"
                else
                  "The story could not be imported. (#{error.message})"
                end
            }
          }
        )

        timeout_retry(3) do
          hook.publish
        end
      end
    end
  end
end

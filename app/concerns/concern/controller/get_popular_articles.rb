module Concern
  module Controller
    module GetPopularArticles
      private
      def get_popular_articles
        # We have to rescue here because Marshal doesn't know about
        # Rails' autoloading. This should be a non-issue in production,
        # but just in case (and for development), we should be safe.
        # This is fixed in Rails 4.
        # https://github.com/rails/rails/issues/8167
        prev_klass = nil

        begin
          @popular_articles = Rails.cache.read("popular/viewed")
        rescue ArgumentError => e
          klass = e.message.match(/undefined class\/module (.+)\z/)[1]

          # If we already tried to load this class but couldn't,
          # give up.
          if klass == prev_klass
            warn "Error caught: Couldn't deserialize popular articles: #{e}"
            @popular_articles = nil
            return
          end

          prev_klass = klass
          klass.constantize # Let Rails load it for us.
          retry
        end
      end
    end
  end
end

require "#{Rails.root}/vendor/lib/apple-news/papi-client/api"
require 'tempfile'
require 'tmpdir'
require 'open-uri'

module Job
  class PublishAppleNewsContent < Base
    # @priority = :mid
    class << self
      def perform content_type, id, action
        record = content_type.constantize.find(id)
        # The gem provided by Apple expects a JSON file.  Specifically, it wants a file called
        # 'article.json', and refuses any file that has a different name.  Since we don't really
        # want to manage a bunch of JSON files, I've modified the gem to take in a file with any
        # name we specify, but it still tells the API that it's called "article.json" upon request.
        action = action.to_s
        record.apple_news_api_call action
      end
    end

  end
end
require 'oauth2'

module Job
  class MostViewedBlogEntries < Base
    @priority = :low

    TOKEN_URL = "https://accounts.google.com/o/oauth2/token"
    AUTH_URL  = "https://accounts.google.com/o/oauth2/auth"
    API_URL   = "https://www.googleapis.com"
    API_PATH  = "/analytics/v3/data/ga"


    class << self
      def perform
        analytics = Rails.configuration.x.api.google.analytics

        task = new(
          analytics["client_id"],
          analytics["client_secret"],
          analytics["token"],
          analytics["refresh_token"]
        )

        blogs = Blog.active.map(&:slug)

        blogs.each do |blog|
          data = silence_stream(STDOUT) { task.fetch(api_params(blog)) }
          if blog_entry = task.parse(data['rows'])
            article = blog_entry.to_article
            Cache.write("popular/#{blog}", article)
            self.cache(
              article,
              "/shared/widgets/cached/popular_blog",
              "views/popular/#{blog}",
              local: :article
            )
          end
        end
      end

      #---------------

      private

      def api_params(filter)
        {
          "ids"         => "ga:1028848",
          "metrics"     => "ga:pageviews",
          "dimensions"  => "ga:pagePath",
          "max-results" => "1",
          "filters"     => "ga:pagePath=~/blogs\/#{filter}/.+$",
          "sort"        => "-ga:pageviews",
          "pp"          => "1",
          "start-date"  => Date.today - 2,
          "end-date"    => Date.today
        }
      end
    end


    #---------------

    def initialize(client_id, client_secret, token, refresh_token)
      @client_id     = client_id
      @client_secret = client_secret
      @token         = token
      @refresh_token = refresh_token
      @oauth_token   = oauth_token
    end

    #---------------

    def fetch(api_params={})
      resp = connection.get do |req|
        req.url API_PATH, api_params
      end

      resp.body
    end

    add_transaction_tracer :fetch, category: :task

    #---------------

    def parse(rows)
      row = rows.first
      if article = ContentBase.obj_by_url(row[0])
        self.log "(#{row[1]}) #{row[0]}"
        return article
      end
    end

    add_transaction_tracer :parse, category: :task


    #---------------

    private

    def client
      @client ||= begin
        OAuth2::Client.new(
          @client_id, @client_secret, {
          :authorization_url => AUTH_URL,
          :token_url         => TOKEN_URL
        })
      end
    end

    #---------------

    def oauth_token
      token = OAuth2::AccessToken.new(
        client, @token, refresh_token: @refresh_token)

      token.refresh!
    end

    #---------------

    def connection
      @connection ||= begin
        Faraday.new API_URL, headers: {
          "Authorization" => "Bearer #{@oauth_token.token}"
        } do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use Faraday::Response::Logger
          builder.use FaradayMiddleware::ParseJson, content_type: /\bjson\z/
          builder.adapter Faraday.default_adapter
        end
      end
    end
  end # MostViewed
end # Job


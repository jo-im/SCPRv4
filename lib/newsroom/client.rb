module Newsroom
  class Client
    attr_accessor :data, :path

    def initialize(options={})
      @path = options[:path]
      @data = options[:data] || { touch: true }
    end

    # Publish the message
    def publish
      response = connection.post do |request|
        request.url @path
        request.params = @data
      end

      response
    end


    private

    def connection
      @connection ||= begin
        Faraday.new(url: Rails.application.config.newsroom.server) do |conn|
          conn.response :json
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end

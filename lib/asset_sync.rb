class AssetSync
  def initialize
    @config = Rails.application.secrets["assethost_pubsub"]
    @redis  = Redis.new( url:@config["redis"] )
    $stderr.puts "Connected to Redis for Pub/Sub on #{ @config["redis"] }"
  end

  #----------

  def work
    @redis.subscribe(@config["key"]) do |on|
      on.subscribe do |channel,subscriptions|
        $stderr.puts "Subscribed to #{ channel }"
      end

      on.message do |channel,message|
        # message will be a simple JSON object with an :action and an :id
        # in either case we'll just delete the cache for now
        obj = JSON.parse(message)
        key = "asset/asset-#{obj['id']}"

        $stderr.puts("Expiring #{key}")

        Rails.cache.delete(key)
      end

      on.unsubscribe do |channel,subscriptions|
        $stderr.puts "Unsubscribed from #{channel}"
      end
    end
  end
end
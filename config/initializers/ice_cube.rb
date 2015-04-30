module IceCube
  module TimeUtil
    # Serialize a time appropriate for storing
    def self.serialize_time(time)
      if time.respond_to?(:iso8601)
        time.iso8601
      else
        time
      end
    end

    # Deserialize a time serialized with serialize_time
    def self.deserialize_time(time_or_hash)
      if time_or_hash.is_a?(String)
        if Time.respond_to?(:zone)
          Time.zone.parse(time_or_hash)
        else
          Time.parse(time_or_hash)
        end
      elsif time_or_hash.is_a?(Time)
        time_or_hash
      elsif time_or_hash.is_a?(Hash)
        time_or_hash[:time].in_time_zone(time_or_hash[:zone])
      end
    end
  end
end
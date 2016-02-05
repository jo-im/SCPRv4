class Cache < ActiveRecord::Base
  class << self
    def read key
      if value = Rails.cache.read(key)
        value
      elsif value = where(key: key).limit(1).pluck(:value).pop
        Rails.cache.write key, value
        value
      end
    end
    def write key, value
      if return_value = Rails.cache.write(key, value)
        return_value
      else
        create key: key, value: value
        value
      end
    end
    def clear
      delete_all
    end
  end
end

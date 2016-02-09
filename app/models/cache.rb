class Cache < ActiveRecord::Base
  class << self
    def read key
      if value = Rails.cache.read(key)
        value
      elsif value = find_by(key: key).try(:value)
        Rails.cache.write key, value
        value
      end
    end
    def write key, value
      Rails.cache.write(key, value)
      where(key: key).first_or_create(value: value)
      value
    end
    def clear
      delete_all
    end
  end
end

module StatusBuilder
  class Status
    attr_accessor \
      :key,
      :id,
      :text,
      :type


    def initialize(key, attributes={})
      self.key    = key
      self.id     = attributes[:id]
      self.text   = attributes[:text]
      self.type   = attributes[:type]
    end


    # Set the status type to unpublished
    def unpublished!
      self.type = :unpublished
    end


    # Set the status type to pending
    def pending!
      self.type = :pending
    end


    # Set the status type to published
    def published!
      self.type = :published
    end
  end
end

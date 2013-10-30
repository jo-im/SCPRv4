module Secretary
  module VersionedAttributes
    extend ActiveSupport::Concern

    included do
      self.versioned_attributes = self.column_names
    end

    module ClassMethods
      attr_accessor :versioned_attributes
    end

    def version_hash
      self.attributes.select do |k, v|
        self.class.versioned_attributes.include?(k)
      end
    end
  end
end

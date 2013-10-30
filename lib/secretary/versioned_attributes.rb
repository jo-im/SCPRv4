module Secretary
  module VersionedAttributes
    extend ActiveSupport::Concern

    included do
      class << self
        attr_writer :versioned_attributes
        def versioned_attributes
          @versioned_attributes ||=
            self.column_names - self.unversioned_attributes
        end

        attr_writer :unversioned_attributes
        def unversioned_attributes
          @unversioned_attributes ||= []
        end
      end
    end


    def version_hash
      self.attributes.select do |k, _|
        self.class.versioned_attributes.include?(k)
      end
    end
  end
end

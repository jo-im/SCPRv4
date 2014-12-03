##
# Generate a teaser from body if it's blank.
#
module Concern
  module Callbacks
    module GenerateBodyCallback
      extend ActiveSupport::Concern

      included do
        before_validation :generate_body, if: :should_generate_body?
      end

      def should_generate_body?
        self.should_validate? && self.body.blank?
      end

      def generate_body
        if self.teaser.present?
          self.body = self.teaser
        end
      end
    end
  end
end

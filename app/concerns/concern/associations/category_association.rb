##
# CategoryAssociation
#
# Defines category association
# Required attributes:
# * category_id
# * published?
# * unpublishing?
module Concern
  module Associations
    module CategoryAssociation
      extend ActiveSupport::Concern

      included do
        belongs_to :category

        promise_to :touch_category, :if => :should_touch_category?
      end


      private

      def should_touch_category?
        self.category.present? && (self.published? || self.unpublishing?)
      end

      def touch_category
        self.category.touch
      end
    end # CategoryAssociation
  end # Associations
end # Concern

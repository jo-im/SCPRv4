##
# CategoryAssociation
#
# Defines category association
# Required attributes:
# * category_id
# * published?
# * unpublishing?
#
# I recommend including StatusMethods into your class if possible.
module Concern
  module Associations
    module CategoryAssociation
      extend ActiveSupport::Concern

      included do
        belongs_to :category

        after_save :promise_to_touch_category,
          :if => :should_touch_category?

        after_commit :touch_category,
          :if => :promised_to_touch_category?
      end


      private

      def should_touch_category?
        self.category.present? && (self.published? || self.unpublishing?)
      end

      def promise_to_touch_category
        @promise_to_touch_category = true
      end

      def promised_to_touch_category?
        !!@promise_to_touch_category
      end

      def touch_category
        @promise_to_touch_category = nil
        self.category.try(:touch)
      end
    end # CategoryAssociation
  end # Associations
end # Concern

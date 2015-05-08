module Concern
  module Associations
    module TagsAssociation
      extend ActiveSupport::Concern

      included do
        has_many :taggings, as: :taggable, dependent: :destroy
        has_many :tags, through: :taggings

        if self.has_secretary?
          tracks_association :tags
        end

        after_save :touch_tags, if: :should_touch_tags?
      end


      private

      # Since this module is shared across several models,
      # we only want to touch the tags if the object is publishable
      # and is currently being published.
      def should_touch_tags?
        self.respond_to?(:publishing?) && self.publishing?
      end

      # Touch the tags so we can use their "updated_at" data
      # to populate the "coverage began/ended" metadata on the
      # Issues pages.
      def touch_tags
        tags.each {|t| t.update_timestamps(published_at)}
      end
    end
  end
end

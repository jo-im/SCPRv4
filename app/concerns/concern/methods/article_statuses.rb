# Defines some shared statuses between all of the "Article" models
# Also defines the "publish" directive for these models.
module Concern
  module Methods
    module ArticleStatuses
      extend ActiveSupport::Concern

      included do
        has_status

        status :killed do |s|
          s.id = -1
          s.text = "Killed"
          s.unpublished!
        end

        status :draft do |s|
          s.id = 0
          s.text = "Draft"
          s.unpublished!
        end

        status :awaiting_rework do |s|
          s.id = 1
          s.text = "Awaiting Rework"
          s.unpublished!
        end

        status :awaiting_edits do |s|
          s.id = 2
          s.text = "Awaiting Edits"
          s.unpublished!
        end

        status :pending do |s|
          s.id = 3
          s.text = "Pending"
          s.pending!
        end

        status :live do |s|
          s.id = 5
          s.text = "Published"
          s.published!
        end
      end


      # Publish this article
      def publish
        self.update_attributes(status: self.class.status_id(:live))
      end
    end
  end
end

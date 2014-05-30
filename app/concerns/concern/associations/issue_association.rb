##
# IssueAssociation
#
# Defines issue association
#
module Concern
  module Associations
    module IssueAssociation
      extend ActiveSupport::Concern

      included do
        has_many :article_issues,
          :as           => :article,
          :dependent    => :destroy

        has_many :issues, through: :article_issues

        promise_to :touch_issues, :if => :should_touch_issues?
      end


      def issue_ids=(issues)
        if self.respond_to?(:tag_ids=)
          issues = Issue.where(id: issues).all
          tags = Tag.where(slug: issues.map(&:slug))

          self.tag_ids = tags.map(&:id)
        else
          super
        end
      end

      private

      def should_touch_issues?
        self.issues.present? && (self.published? || self.unpublishing?)
      end

      def touch_issues
        self.issues.each(&:touch)
      end
    end # IssueAssociation
  end # Associations
end # Concern

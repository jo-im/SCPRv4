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

        after_commit :touch_issues
      end


      private

      def touch_issues
        self.issues.each(&:touch)
      end
    end # IssueAssociation
  end # Associations
end # Concern


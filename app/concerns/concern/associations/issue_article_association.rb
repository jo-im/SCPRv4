##
# IssueAssociation
#
# Defines issue association
#
module Concern
  module Associations
    module IssueArticleAssociation
      extend ActiveSupport::Concern

      included do
        has_many :article_issues, as: :article
        has_many :issues, through: :article_issues
      end

      def issues_in_category
        return [] if category.blank?
        (issues - (issues - category.issues))
      end

    end # IssueArticleAssociation
  end # Associations

end # Concern


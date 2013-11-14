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

      def issue_in_category
       (issues - (issues - category.issues)).first
      end

    end # IssueArticleAssociation
  end # Associations

end # Concern


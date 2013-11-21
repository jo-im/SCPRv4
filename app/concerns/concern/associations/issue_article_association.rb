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
        if category.present?
          if issues.presence && category.issues.presence
            (issues - (issues - category.issues))
          end
        end
      end

    end # IssueArticleAssociation
  end # Associations

end # Concern


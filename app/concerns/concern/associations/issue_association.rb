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
      end
    end # IssueAssociation
  end # Associations
end # Concern


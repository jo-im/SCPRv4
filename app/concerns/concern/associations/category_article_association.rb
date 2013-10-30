##
# CategoryArticleAssociation
#
# Defines category-article association
#
module Concern
  module Associations
    module CategoryArticleAssociation
      extend ActiveSupport::Concern

      included do
        has_many :category_articles, as: :article
      end
    end # CategoryArticleAssociation
  end # Associations
end # Concern



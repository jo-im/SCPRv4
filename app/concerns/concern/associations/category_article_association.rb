##
# CategoryArticleAssociation
#
# Defines category-article association
# Must respond to `unpublishing?`
module Concern
  module Associations
    module CategoryArticleAssociation
      extend ActiveSupport::Concern

      included do
        has_many :category_articles,
          :as           => :article,
          :dependent    => :destroy

        after_save :_destroy_category_articles,
          :if => -> { self.unpublishing? }
      end


      private

      def _destroy_category_articles
        self.category_articles.clear
      end
    end # CategoryArticleAssociation
  end # Associations
end # Concern



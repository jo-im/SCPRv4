##
# VerticalArticleAssociation
#
# This is here so that when an article is unpublished,
# it will be removed from any associated verticals as well.
# Must respond to `unpublishing?`
module Concern
  module Associations
    module VerticalArticleAssociation
      extend ActiveSupport::Concern

      included do
        has_many :vertical_articles,
          :as           => :article,
          :dependent    => :destroy

        after_save :_destroy_vertical_articles,
          :if => -> { self.unpublishing? }
      end


      private

      def _destroy_vertical_articles
        self.vertical_articles.clear
      end
    end # VerticalArticleAssociation
  end # Associations
end # Concern



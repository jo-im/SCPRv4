##
# ProgramArticleAssociation
#
# This is here so that when an article is unpublished,
# it will be removed from any associated programs as well.
# Must respond to `unpublishing?`
module Concern
  module Associations
    module ProgramArticleAssociation
      extend ActiveSupport::Concern

      included do
        has_many :program_articles,
          :as           => :article,
          :dependent    => :destroy

        after_save :_destroy_program_articles,
          :if => -> { self.unpublishing? }
      end


      private

      def _destroy_program_articles
        self.program_articles.clear
      end
    end # ProgramArticleAssociation
  end # Associations
end # Concern


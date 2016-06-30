##
# Reverse-Association with HomepageContent.
#
# For registering callbacks for deleting/unpublishing.
# Requires: [:unpublishing?]
#
module Concern
  module Associations
    module HomepageContentAssociation
      extend ActiveSupport::Concern

      included do
        has_many :homepage_contents,
          :as           => :content,
          :dependent    => :destroy

        after_save :_destroy_homepage_contents,
          :if => -> { self.unpublishing? }

        after_commit :update_better_homepage_cache, if: :on_current_homepage?

        has_many :better_homepages, through: :homepage_contents, source_type: :BetterHomepage, source: :homepage
      end

      private

      def update_better_homepage_cache
        if homepage = homepage_if_on_current
          homepage.touch
        end
      end

      def on_current_homepage?
        better_homepages.current.include? BetterHomepage.current.last
      end

      def homepage_if_on_current
        homepage = BetterHomepage.current.last
        if better_homepages.current.include? homepage
          homepage
        end
      end

      def _destroy_homepage_contents
        self.homepage_contents.clear
      end
    end
  end
end

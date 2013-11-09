##
# Reverse-Association with FeaturedComment.
#
# For registering callbacks for deleting/unpublishing.
# Requires: [:unpublishing?]
#
module Concern
  module Associations
    module QuoteAssociation
      extend ActiveSupport::Concern

      included do
        has_many :quotes,
          :as           => :article,
          :dependent    => :destroy

        after_save :_destroy_quotes, if: -> { self.unpublishing? }
      end


      private

      def _destroy_quotes
        self.quotes.clear
      end
    end
  end
end


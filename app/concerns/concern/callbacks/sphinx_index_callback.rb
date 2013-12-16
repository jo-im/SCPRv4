##
# Enqueue a sphinx index for this model.
#
# NOTE: This module should be included *before* HomepageCachingCallback,
# so that the callbacks are registered in the correct order.
module Concern
  module Callbacks
    module SphinxIndexCallback
      extend ActiveSupport::Concern

      included do
        promise_to :enqueue_sphinx_index_for_class,
          :if => :should_enqueue_sphinx_index_for_class?
      end


      module ClassMethods
        def enqueue_sphinx_index
          Indexer.enqueue(self.name)
        end
      end


      private

      def should_enqueue_sphinx_index_for_class?
        self.changed? || self.destroyed?
      end

      # Enqueue a sphinx index for this model
      def enqueue_sphinx_index_for_class
        self.class.enqueue_sphinx_index
      end
    end
  end
end

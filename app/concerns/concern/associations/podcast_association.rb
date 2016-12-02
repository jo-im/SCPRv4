module Concern
  module Associations
    module PodcastAssociation
      extend ActiveSupport::Concern

      included do
        has_one :podcast, as: :source
      end

    end
  end
end

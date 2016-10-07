module Concern
  module Associations
    module PodcastAssociation
      extend ActiveSupport::Concern

      included do
        has_one :podcast, as: :source
      end

      def podcast_tile
        podcast.try(:image_url) || "/static/images/default-listen-live-tile.jpg"
      end

    end
  end
end

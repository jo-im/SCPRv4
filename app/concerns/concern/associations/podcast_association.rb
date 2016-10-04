module Concern
  module Associations
    module PodcastAssociation
      extend ActiveSupport::Concern

      included do
        has_one :podcast, as: :source
      end

      def podcast_tile
        podcast.try(:image_url) || "http://media.scpr.org/assets/images/podcasts/kpcc-podcast-cover-theride.jpg"
      end

    end
  end
end

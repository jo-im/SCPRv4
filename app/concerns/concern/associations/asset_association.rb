##
# AssetAssociation
#
# Association for Asset
#
module Concern
  module Associations
    module AssetAssociation
      extend ActiveSupport::Concern

      ASSET_DISPLAY_IDS = {
        :slideshow    => 0,
        :video        => 1,
        :photo        => 2,
        :hidden       => 3
      }

      ASSET_DISPLAYS = ASSET_DISPLAY_IDS.invert


      included do
        has_many :assets, {
          :class_name => "ContentAsset",
          :as         => :content,
          :order      => "position",
          :dependent  => :destroy,
          :autosave   => true
        }

        accepts_json_input_for_assets

        if self.has_secretary?
          tracks_association :assets
        end
      end

      #--------------------

      def asset
        @asset ||= (self.assets.first || AssetHost::Asset::Fallback.new)
      end


      # The symbol for the asset display
      def asset_display
        if self.respond_to?(:asset_display_id)
          ASSET_DISPLAYS[self.asset_display_id]
        end
      end

      # Set the asset_display_id.
      # Accepts a symbol
      def asset_display=(value)
        if self.respond_to?(:asset_display_id=)
          self.asset_display_id = ASSET_DISPLAY_IDS[value]
        end
      end
    end # AssetAssociation
  end # Associations
end # Concern

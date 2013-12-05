# Asset display read/write.
# Required:
# * AssetAssociation
# * asset_display_id
#
# This is here because we don't want an AssetAssociation to also require
# the AssetDisplay stuff.
module Concern
  module Methods
    module AssetDisplayMethods
      ASSET_DISPLAY_IDS = {
        :slideshow    => 0,
        :video        => 1,
        :photo        => 2,
        :hidden       => 3
      }

      ASSET_DISPLAYS = ASSET_DISPLAY_IDS.invert


      # The symbol for the asset display
      def asset_display
        ASSET_DISPLAYS[self.asset_display_id]
      end

      # Set the asset_display_id.
      # Accepts a symbol
      def asset_display=(value)
        self.asset_display_id = ASSET_DISPLAY_IDS[value]
      end
    end
  end
end

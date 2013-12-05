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
      class << self
        def select_collection
          ContentBase::ASSET_DISPLAYS.map { |k,v| [v.to_s.titleize, k] }
        end
      end

      # The symbol for the asset display
      def asset_display
        ContentBase::ASSET_DISPLAYS[self.asset_display_id]
      end

      # Set the asset_display_id.
      # Accepts a symbol
      def asset_display=(value)
        self.asset_display_id = ContentBase::ASSET_DISPLAY_IDS[value]
      end
    end
  end
end

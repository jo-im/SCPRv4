##
# AssetAssociation
#
# Association for Asset
#
module Concern
  module Associations
    module AssetAssociation
      extend ActiveSupport::Concern

      included do
        has_many :assets,
          -> { order('position') },
          :class_name => "ContentAsset",
          :as         => :content,
          :dependent  => :destroy,
          :autosave   => true

        accepts_json_input_for_assets

        if self.has_secretary?
          tracks_association :assets
        end
      end

      #--------------------

      def asset
        @asset ||= (self.assets.top.first || AssetHost::Asset::Fallback.new)
      end
    end # AssetAssociation
  end # Associations
end # Concern

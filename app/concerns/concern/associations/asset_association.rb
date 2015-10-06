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

        before_save :update_inline_assets

      end

      #--------------------

      def asset
        @asset ||= (self.assets.top.first || AssetHost::Asset::Fallback.new)
      end

      #--------------------

      def mark_inline_assets
        doc = Nokogiri::HTML body
        inline_asset_ids = doc.css("img.inline-asset").map{|placeholder| placeholder.attr("data-asset-id").to_s}
        assets.each do |asset|
          if inline_asset_ids.include? asset.asset_id.to_s
            asset.inline = true
          else
            asset.inline = false
          end
        end
      end

      #--------------------

      def update_inline_assets
        mark_inline_assets
        ActiveRecord::Base.transaction do 
          assets.each(&:save!)
        end
      end

    end # AssetAssociation
  end # Associations
end # Concern

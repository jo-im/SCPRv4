module Concern::Model::InlineAssets
  extend ActiveSupport::Concern

  included do
    before_save :update_inline_assets
  end

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

  def update_inline_assets
    mark_inline_assets
    ActiveRecord::Base.transaction do 
      assets.each(&:save!)
    end
  end

end
class ContentAsset < ActiveRecord::Base
  include Outpost::AssetHost::JoinModelJson
  include Concern::Associations::PmpContentAssociation::ImageProfile

  PMP_PROFILE = "image"

  self.table_name =  "assethost_contentasset"
  self.versioned_attributes = ["position", "asset_id", "caption"]

  scope :top, ->{where(inline:false)}
  scope :inline, ->{where(inline:true)}

  belongs_to :content, polymorphic: true, touch:true

  delegate \
    :title,
    :size,
    :taken_at,
    :owner,
    :url,
    :api_url,
    :native,
    :image_file_size,
    :lsquare,
    :small,
    :eight,
    :full,
    :wide,
    :three,
    :thumb,
    to: :asset

  alias_attribute :primary, :full
  alias_attribute :large, :full
  alias_attribute :medium, :wide
  alias_attribute :square, :lsquare

  def asset
    @asset ||= begin
      if self.external_asset.present?
        # Cache with the content_asset id since there is no valid asset_id
        _asset = Rails.cache.fetch("/content_asset/#{self.id}/external", expires_in: 1.hour) do
          external_asset_metadata = JSON.parse(self.external_asset)

          # Create an asset from the fallback asset so that we can retain the expected shape
          external_asset = AssetHost::Asset::Fallback.new
          external_asset.json["id"] = 0
          external_asset.json["title"] = external_asset_metadata["title"]
          external_asset.json["caption"] = external_asset_metadata["caption"]
          external_asset.json["owner"] = external_asset_metadata["owner"]
          external_asset.json["url"] = external_asset_metadata["url"]

          # Since we don't have the usual cuts from an external image that we get from AssetHost,
          # populate each size property and tag with the same url.
          # Note: We're assuming that there are the same number of urls as there are tags
          external_asset.json["urls"].each do |size|
            size_property = size.first
            external_asset.json["urls"][size_property] = external_asset_metadata["url"]
            external_asset.json["tags"][size_property] = "<img src=\"#{external_asset_metadata["url"]}\" />"
          end

          # Return an asset object. Instantiating it like this doesn't perform a POST
          AssetHost::Asset.new(external_asset.json)
        end
      elsif self.asset_id.present? && self.asset_id != 0
        _asset = Rails.cache.fetch("/content_asset/#{self.asset_id}", expires_in: 15.minutes) do
          AssetHost::Asset.find(self.asset_id)
        end
      else
        _asset = AssetHost::Asset::Fallback.new
      end

      if _asset.is_a? AssetHost::Asset::Fallback
        self.caption = "We encountered a problem, and this photo is currently unavailable."
      end

      _asset
    end
  end

  def use
    inline ? "inline" : "standard"
  end

  def orientation
    if asset
      {
        "portrait"  => "portrait",
        "landscape" => "wide",
        "square"    => "square"
      }[asset.json["orientation"]]
    end
  end

  def kpcc?
    (owner || "").include? "KPCC"
  end

end

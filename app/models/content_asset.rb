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
      _asset = Rails.cache.fetch("/content_asset/#{self.asset_id}", expires_in: 15.minutes) do
        AssetHost::Asset.find(self.asset_id)
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

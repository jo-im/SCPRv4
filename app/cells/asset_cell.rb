class AssetCell < Cell::ViewModel

  property :owner

  def show

    article = @options[:article]

    context = @options[:context] || "default"

    return if asset && @options[:kpcc_only] && !asset.try(:owner).try(:include?, "KPCC")

    if @options[:template]
      tmplt_opts = Array(@options[:template])
    else
      tmplt_opts = [
        "#{context}/#{display}",
        "default/#{display}",
        "#{context}/photo",
        "default/photo"
      ]
    end

    partial = tmplt_opts.find do |template|
      File.exist?("#{Rails.root}/#{self.class.prefixes[0]}/#{template}.erb")
    end

    partial ||= tmplt_opts.last

    render view: partial

  end

  def aspect asset=model
    width = asset.small.width.to_i
    height = asset.small.height.to_i
    if width < height
      "o-figure--portrait"
    else
      if @options[:featured]
        "o-figure--classic"
      else
        "o-figure--full"
      end
    end
  end

  def slideshow_assets
    assets.try(:select) {|a| a.inline == false }
  end

  def article
    @options[:article]
  end

  def caption
    (model.caption.blank? ? nil : model.caption) || ""
  end

  def assets
    article.try(:assets) || []
  end

  def asset
    model || @options[:asset] || article.asset || nil
  end

  def src
    model.try(:full).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def public_url
    @options[:article].try(:public_url)
  end

  def display
    if article.try(:asset_display) || @options[:display]
      article.asset_display.to_s
    else
      "photo"
    end
  end

  def title
    model.title || model.caption
  end

  def assethost
    if assets.first.try(:eight).try(:asset).try(:native)
      assets.first.eight.asset.native["class"]
    end
  end

  def videoid
    if assets.first.try(:eight).try(:asset).try(:native)
      assets.first.eight.asset.native["videoid"]
    end
  end

end


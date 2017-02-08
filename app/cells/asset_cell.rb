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

  def aspect
    if model.small.width.to_i < model.small.height.to_i
      "o-figure--four-by-three"
    else
      "o-figure--widescreen"
    end
  end

  def article
    @options[:article]
  end

  def caption
    (model.caption.blank? ? nil : model.caption) || model.title || ""
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

end


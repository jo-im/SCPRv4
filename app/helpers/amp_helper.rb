module AmpHelper
  def amp_timestamp datetime
    if datetime.respond_to?(:strftime)
      time_tag(datetime,
        format_date(datetime,
          :format   => :full_date,
          :time     => true
        )
      )
    end
  end
  def amp_image url, options
    # requires a width and a height
    return nil if !options[:width] || !options[:height]
    content_tag("amp-img", nil, {src: url}.merge(options)).html_safe
  end
  def amp_asset asset, options={}
    full_asset = asset.full
    attributes = {
      width: full_asset.width, 
      height: full_asset.height,
      alt: asset.caption,
      title: asset.caption,
      attribution: asset.owner
    }
    attributes[:srcset] = full_asset.url
    attributes[:srcset] = [
      asset.small,
      asset.large
    ].compact.map do |asset|
      "#{asset.url} #{asset.width}w"
    end.join(', ')
    amp_image full_asset.url, attributes.merge(options)
  end
end
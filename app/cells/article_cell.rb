# As in an actual Article and not one of our ContentBase models.
# NEVER not an Article.  NOT original_object -- DON'T DO IT.
# NO, JUST NO.  If it's not there, add it to the Article class.

class ArticleCell < Cell::ViewModel
  include ActionView::Helpers::DateHelper
  property :title
  property :body
  property :assets
  property :asset
  property :category

  cache :show do
    model.try(:cache_key)
  end

  def show
    render
  end

  def audio_nav
    render
  end

  def biographies links=true
    elements = model.try(:joined_bylines) do |bylines|
      bylines.map do |byline|
        if links && byline.user.try(:is_public)
          link_to byline.display_name, byline.user.public_path
        else
          byline.display_name
        end
      end
    end
    elements || {}
  end

  def contributing_byline
    if biographies[:contributing] && biographies[:contributing].length > 0
      "With contributions from #{biographies[:contributing]}".html_safe
    end
  end

  def pij_source options={}
    message = options[:message] || "This story was informed by KPCC listeners."

    if model.try(:is_from_pij?)
      render locals: { message: message }
    end
  end

  def asset_path(resource)
    resource.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def hero_asset(figure_class)
    if model.try(:asset_display) != :hidden || !model.try(:assets).try(:empty?)
      AssetCell.new(asset, article: model, class: figure_class).call(:show)
    end
  end

  def render_body options={}
    cssPath = "img.inline-asset[data-asset-id]"
    context = options[:context] || "news"
    display = options[:display] || "inline"
    doc = Nokogiri::HTML(body)
    doc.css(cssPath).each do |placeholder|
      asset_id = placeholder.attribute('data-asset-id').value
      asset_id = asset_id ? asset_id.to_i : nil
      next if asset_id.nil?

      # we have to fall back to original_object here to get the full list of
      # assets. in any case where we're rendering a body, we'll already have
      # the original object loaded, so that's ok
      asset = model.try(:inline_assets).select{|a| a.asset_id == asset_id}[0]

      ## If kpcc_only is true, only render if the owner of the asset is KPCC
      if asset && (!options[:kpcc_only] || asset.owner.try(:include?, "KPCC"))
        positioning    = (asset.small.width.to_i < asset.small.height.to_i) ? "o-article__body--float-right" : ''
        rendered_asset = AssetCell.new(asset, context: context, display: display, article: model, class: positioning).call(:show)
        placeholder.replace Nokogiri::HTML::DocumentFragment.parse(rendered_asset)
      else
        # FIXME: I'm sure there's a cleaner "delete"
        placeholder.replace Nokogiri::HTML::DocumentFragment.parse("")
      end
    end
    order_body doc
    doc.css("body").children.to_s.html_safe
  end

  def order_body doc
    doc.css("body > *").each_with_index do |element, i|
      element['style'] ||= ""
      unless element['style'].match(/order:\s(.*);/)
        element['style'] += "order:#{i}; height: 100%;"
      end
    end
  end

  def byline links=true
    return "KPCC" if !model.respond_to?(:joined_bylines)
    elements = model.joined_bylines do |bylines|
      bylines.map do |byline|
        if links && byline.user.try(:is_public)
          link_to byline.display_name, byline.user.public_path
        else
          byline.display_name
        end
      end
    end
    ContentByline.digest(elements).html_safe
  end

  # #----------
  # # Render a timestamp inside of a time tag.
  # #
  # # time_tag uses i18n's `localize` method, which raises
  # # if the date passed in doesn't respond to strftime, so we
  # # need to check that this is the case before rendering the
  # # time tag. Otherwise previewing unpublished content breaks.
  # def timestamp
  #   datetime = model.public_datetime
  #   if datetime.respond_to?(:strftime)
  #     time_tag(datetime,
  #       format_date(datetime,
  #         :format   => :full_date,
  #         :time     => true
  #       ),
  #       :pubdate => true
  #     )
  #   end
  # end

  def timestamp
    datetime = model.public_datetime.try(:strftime, "%B %-d, %Y")
    if datetime
      "<time datetime=\"#{model.public_datetime.try(:iso8601)}\">" +
        datetime +
      "</time>"
    end
  end

  def format_date time, format=:long, blank_message="&nbsp;"
    time.blank? ? blank_message : time.to_s(format)
  end

end

class BlogEntryCell < Cell::ViewModel
  def show
    render
  end

  def asset_path
    model.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def byline links=true
    original_object = model.try(:original_object) || model
    return "KPCC" if !original_object.respond_to?(:joined_bylines)
    elements = original_object.joined_bylines do |bylines|
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

  def aspect
    if model.asset.small.width.to_i < model.asset.small.height.to_i
      'portrait'
    else
      'widescreen'
    end
  end

  def has_comments?(object)
    object.respond_to?(:disqus_identifier)
  end

  def comment_count_for(object, options={})
    if has_comments?(object)
      options[:class] = "comment_link social_disq #{options[:class]}"
      options["data-objkey"] = object.disqus_identifier
      link_to("", (object.public_path + "#comments"), options)
    end
  end

end

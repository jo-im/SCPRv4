class StoryListCell < Cell::ViewModel
  def show
    render if (model || []).any?
  end

  def heading
    @options[:heading]
  end

  def style_class
    if @options[:style]
      "o-story-cell--#{@options[:style]}"
    else
      ""
    end
  end

  def asset_path(article)
    article.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def asset_aspect
    @options[:asset_aspect] || "four-by-three"
  end

  #----------
  # Render a byline for the passed-in content
  # If links is set to false, and the content has
  # bylines, this will yield the same as +content.byline+
  #
  # If the content doesn't have bylines, just return
  # "KPCC" for opengraph stuff.
  def render_byline(content, links=true)
    return "KPCC" if !content.respond_to?(:joined_bylines)

    elements = content.joined_bylines do |bylines|
      link_bylines(bylines, links)
    end

    ContentByline.digest(elements).html_safe
  end

  #---------------------------
  # Return an array of the passed-in bylines
  # either tranformed into links, or just
  # the name.
  #
  # This is mostly for +render_byline+ and
  # +render_contributing_byline+ to share.
  def link_bylines(bylines, links)
    bylines.map do |byline|
      if !!links && byline.user.try(:is_public)
        link_to byline.display_name, byline.user.public_path
      else
        byline.display_name
      end
    end
  end

end

class CategoryController < ApplicationController
  respond_to :html, :xml, :rss

  DEFAULT_LIMIT = 15

  def news
    @categories = Category.all
    respond_by_format
  end

  #------------------

  def carousel_content
    @content = params[:object_class].constantize.find(params[:id])
    @carousel_contents = @content.category.content(
      :page       => params[:page],
      :per_page   => 4,
      :exclude    => @content
    )

    render 'shared/cwidgets/content_carousel.js.erb'
  end


  #------------------

  private

  #------------------
  # Respond according to format requested
  def respond_by_format
    if request.format.html?
      # Only need to setup the sections if we're going to
      # render them as HTML
      @top      = get_content(limit: 1).first
      @sections = Category.previews(categories: @categories, exclude: @top)
    else
      # Otherwise just return the latest 15 news items
      @content = get_content
      respond_with @content
    end
  end

  #------------------
  # Get Content
  def get_content(options={})
    # make sure categories is an array
    options[:limit] ||= DEFAULT_LIMIT
    enforce_page_limits(options[:limit])

    ContentBase.search({
      :classes     => [NewsStory, BlogEntry, ContentShell, ShowSegment],
      :page        => params[:page],
      :per_page    => options[:limit],
      :with        => { "category.id" => @categories.map(&:id) }
    })
  end

  private
  #----------
  # Enforce both Upper and Lower page limits.
  # Pass in the results per page.
  def enforce_page_limits(per_page)
    enforce_page_lower_limit
    enforce_page_upper_limit(per_page)
  end

  #----------
  # Enforce Lower page limit. This will not allow a page
  # number to be below 1
  def enforce_page_lower_limit
    if params[:page] && params[:page].to_i < 1
      params[:page] = 1
    end
  end

  #----------
  # Enforce an upper limit. Only necessary with Sphinx results.
  def enforce_page_upper_limit(per_page)
    # Reset to page 1 if the requested page is too high
    # Otherwise an error will occur
    # TODO: Fallback to SQL query instead of just cutting it off.
    if params[:page] && params[:page].to_i > MAX_PAGES
      params[:page] = 1
    end
  end
end

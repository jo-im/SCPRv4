# NOTE: This inherits from ApplicationController,
# so any functionality needed for the NEW templates
# has to be included manually.

module CategoryHandler
  extend ActiveSupport::Concern

  included do
    # Help with lazy loading
    helper_method :vertical_articles
    helper_method :vertical_blog_articles
  end


  PER_PAGE = 16

  def handle_vertical
    # Let Rails lazily load these if necessary.
    # For the other stuff like content and featured
    # articles, those will get populated instantly,
    # so we need to defer their loading until they're
    # actually needed in the template.
    @quotes = @category.quotes.published
    @events = @category.events.published.upcoming

    # For HTML requests, we don't want to load the content prematurely
    # (i.e. outside of the cache), and we don't need to respond with
    # the content since a template is being rendered.
    # For XML, RSS, JSON, etc, we should respond with category_content,
    # because vertical_content excludes the lead article, which is
    # meaningless for an XML feed.
    if request.format.html?
      respond_with @category,
        template:  "category/show",
          layout:  "new/vertical"
    else
      respond_with category_content
    end
  end


  def handle_category
    @content = category_content
    respond_with @content, template: "category/simple"
  end


  private

  # All the content for this category, no excludes.
  def category_content
    @category_content ||= @category.content(
          page:      params[:page].to_i,
      per_page:      PER_PAGE
    )
  end


  # Get any content with this category, excluding the lead article,
  # and map them to articles
  def vertical_articles
    @category_content ||= begin
      content_params = {
            page:      params[:page].to_i,
        per_page:      PER_PAGE
      }
      content_params[:exclude] = [@category.featured_articles.first]
      content_params[:exclude].concat(vertical_blog_articles) if @category.featured_blog.present?
      @category.articles(content_params)
    end
  end

  def vertical_blog_articles
    return unless @category.featured_blog.present?
    @blog_articles ||= begin
      content_params = {
        classes:    [BlogEntry],
           with:    { blog: @category.featured_blog.id },
           page:    1,
       per_page:    2
      }
      content_params[:exclude] = @category.featured_articles.first
      @category.articles(content_params)
    end
  end
end

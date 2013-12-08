# NOTE: This inherits from ApplicationController,
# so any functionality needed for the NEW templates
# has to be included manually.

module CategoryHandler
  extend ActiveSupport::Concern

  included do
    # Help with lazy loading
    helper_method \
      :vertical_articles,
      :featured_articles,
      :lead_article
  end


  PER_PAGE = 16

  def handle_vertical
    # Let Rails lazily load these if necessary.
    # For the other stuff like content and featured
    # articles, those will get populated instantly,
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
        :template => "category/show",
        :layout   => "new/vertical"
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
      :page       => params[:page].to_i,
      :per_page   => PER_PAGE
    )
  end


  # Get the hand-curated featured articles for the category
  def featured_articles
    @featured_articles ||= @category.featured_articles
  end


  def lead_article
    @lead_article ||= featured_articles.first
  end


  # Get any content with this category, excluding the lead article,
  # and map them to articles
  def vertical_articles
    @category_content ||= begin
      content_params = {
        :page       => params[:page].to_i,
        :per_page   => PER_PAGE
      }

      content_params[:exclude] = lead_article
      @category.articles(content_params)
    end
  end
end

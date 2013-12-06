# NOTE: This inherits from ApplicationController,
# so any functionality needed for the NEW templates
# has to be included manually.

module CategoryHandler
  PER_PAGE = 16

  def handle_vertical
    @featured_articles  = @category.featured_articles
    @lead_article       = @featured_articles.first

    content_params = {
      page:         params[:page].to_i,
      per_page:     PER_PAGE
    }

    content_params[:exclude] = @lead_article.original_object if @lead_article.present?

    @content = @category.content(content_params)
    @category_articles  = @content.map(&:to_article)
    @events             = @category.events.published.upcoming
    @quote              = @category.quotes.published.first

    respond_with @content,
      :template => "category/show",
      :layout   => "new/vertical"
  end


  def handle_category
    @content = @category.content(
      :page       => params[:page].to_i,
      :per_page   => PER_PAGE
    )

    respond_with @content, template: "category/simple"
  end
end

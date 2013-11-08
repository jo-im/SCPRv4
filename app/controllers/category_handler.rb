module CategoryHandler
  PER_PAGE = 15

  def handle_category
    page      = params[:page].to_i
    per_page  = PER_PAGE
    @content = @category.content(
      :page       => page,
      :per_page   => per_page
    )
    @featured_articles = @category.articles
    @featured_article = @featured_articles.first
    @resources = @featured_articles[1..4]
    @featured_image = @featured_article.asset

    @category_articles = @content.map { |a| a.to_article }
    @latest_articles = @category_articles[1..2]

    if @featured_article.original_object.issues
      @primary_issue = @featured_article.original_object.issues.first
    end

    @top_two_issue_articles ||= @primary_issue.articles.first(2)
    @latest_event = @category.events.first.to_article
    @twitter_feeds = @category.bios.map(&:twitter_handle)
    respond_with @content, template: "category/show", layout: "vertical"
  end
end

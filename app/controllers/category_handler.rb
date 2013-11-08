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
    @featured_image = @featured_article.asset

    @category_articles = @content.map { |a| a.to_article }
    @latest_articles = @category_articles[1..2]

    @resources = @featured_articles[1..4]

    if @issues = @featured_article.original_object.issues
      @primary_issue = @issues.first
      @special_issue = @issues[1]
      @other_issues = @issues[2..3]
    end
    @top_two_issue_articles ||= @primary_issue.articles.first(2)
    @top_two_special_issue_articles ||= @special_issue.articles.first(2)
    @latest_event = @category.events.first.to_article
    @twitter_feeds = @category.bios.map(&:twitter_handle)
    respond_with @content, template: "category/show", layout: "vertical"
  end
end

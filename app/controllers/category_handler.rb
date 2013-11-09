module CategoryHandler
  PER_PAGE = 15

  def handle_category
    page      = params[:page].to_i
    per_page  = PER_PAGE
    @content = @category.content(
      :page       => page,
      :per_page   => per_page
    )
    if @featured_articles = @category.featured_articles.any?
      @lead_article = @featured_articles.first
      @featured_image ||= @lead_article.asset
      @resources = @featured_articles[1..4]
      @featured_interactive = @featured_articles[5]

      if @issues = @lead_article.original_object.issues.any?
         @primary_issue = @issues.first
         @top_two_issue_articles = @primary_issue.articles.first(2)
      end

    end

    @category_articles = @content.map { |a| a.to_article }
    @latest_articles = @category_articles[1..2]


    if @category_issues = @category.issues.any?
      @special_issue = @category_issues.first
      @other_issues = @category_issues[1..2]
      @top_two_special_issue_articles ||= @special_issue.articles.first(2)
    end

    if @events = @category.events.published.upcoming.any?
      @latest_event = @events.first.to_article
      @upcoming_events = @events[1..3].map { |a| a.to_article }
    end

    if @quote = @category.quotes.published.any?
      @quote_article = @quote.first.article.to_article
    end

    @twitter_feeds = @category.bios.map(&:twitter_handle)
    respond_with @content, template: "category/show", layout: "vertical"
  end
end

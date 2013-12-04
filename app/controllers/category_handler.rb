# NOTE: This inherits from ApplicationController,
# so any functionality needed for the NEW templates
# has to be included manually.

module CategoryHandler
  PER_PAGE = 16

  def handle_vertical
    page      = params[:page].to_i
    per_page  = PER_PAGE
    @content = @category.content(
      :page       => page,
      :per_page   => per_page
    )

    if !@category.featured_articles.empty?
      @featured_articles = @category.featured_articles
      @lead_article = @featured_articles.first
      @featured_image = @lead_article.asset
      @resources = @featured_articles[1..4]
      @featured_interactive = @featured_articles[5]

      if @lead_article.original_object.issues.any?
        @primary_issue = @lead_article.original_object.issues.first
        if @primary_issue.present? && @primary_issue.articles.any?
          @primary_issue_articles = @primary_issue.articles
        end
      end

      if @primary_issue_articles.present?
        @featured_content = {articles: @primary_issue_articles.first(2), type: 'issue'}
      elsif @lead_article.original_object.related_content.any?
        @featured_content = {articles: @lead_article.original_object.related_content.first(2), type: 'related'}
      end
    end

    @category_articles = @content.map(&:to_article)

    if @category.issues.any?
      @category_issues = @category.issues
      @special_issue = @category_issues.first
      @other_issues = @category_issues[1..2]
      @top_two_special_issue_articles ||= @special_issue.articles.first(2)
    end

    if @category.events.published.upcoming.any?
      @events = @category.events.published.upcoming
      @latest_event = @events.first.to_article
      @upcoming_events = @events[1..3].map { |a| a.to_article }
    end

    if @category.quotes.published.any?
      @quote = @category.quotes.published.first
      @quote_article = @quote.article.to_article
    end

    if @category.bios.any?
      @bios = @category.bios
      @twitter_handles = @bios.map(&:twitter_handle)
    end
    respond_with @content, template: "category/show", layout: "new/application"
  end

  def handle_category
    page      = params[:page].to_i
    per_page  = PER_PAGE
    @content = @category.content(
      :page       => page,
      :per_page   => per_page
    )

    respond_with @content, template: "category/simple"
  end

end

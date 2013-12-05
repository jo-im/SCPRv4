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

    if @category.featured_articles.present?
      @featured_articles      = @category.featured_articles
      @lead_article           = @featured_articles.first

      if @lead_article.issues.present?
        @primary_issue = @lead_article.issues.first

        if @primary_issue.present? && @primary_issue.articles.present?
          @primary_issue_articles = @primary_issue.articles
        end
      end

      if @primary_issue_articles.present?
        @featured_content = {
          :articles => @primary_issue_articles.first(2),
          :type     => 'issue'
        }

      elsif @lead_article.original_object.related_content.any?
        @featured_content = {
          :articles => @lead_article.original_object.related_content.first(2),
          :type     => 'related'
        }
      end
    end

    @category_articles = @content.map(&:to_article)

    if @category.issues.present?
      @category_issues  = @category.issues
      @special_issue    = @category_issues.first
      @other_issues     = @category_issues[1..2]

      @top_two_special_issue_articles ||= @special_issue.articles.first(2)
    end

    if @category.events.published.upcoming.present?
      @events           = @category.events.published.upcoming
      @latest_event     = @events.first.to_article
      @upcoming_events  = @events[1..3].map { |a| a.to_article }
    end

    @quote = @category.quotes.published.first

    if @category.bios.present?
      @bios = @category.bios
      @twitter_handles = @bios.map(&:twitter_handle)
    end

    respond_with @content,
      :template => "category/show",
      :layout   => "new/vertical"
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

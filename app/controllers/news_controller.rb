class NewsController < NewApplicationController
  layout 'new/single'
  respond_to :html, :xml, :rss

  before_filter :get_popular_articles

  def story
    @story = NewsStory.published.find_by_slug!(params[:slug])
    @related_articles = @story.related_content.first(2) unless @story.related_content.empty?

    @popular_articles = Rails.cache.read("popular/viewed").first(3) if Rails.cache.read("popular/viewed").presence

    if @category = @story.category
      if @category.issues.present?
        @category_issues = @category.issues
        @special_issue = @category_issues.first
        @other_issues = @category_issues[1..2]
        @top_two_special_issue_articles ||= @special_issue.articles.first(2)
      end

      page      = params[:page].to_i
      @content = @category.content(
        :page       => page,
        :per_page   => 11
      )

      if @content.present?
        @category_articles = @content.map { |a| a.to_article }
        @three_recent_articles = @category_articles[0..2]
        @more_articles = @category_articles[3..-1]
      end

      if @category.featured_articles.present?
        @resources = @category.featured_articles[1..4]
      end

      if @category.bios.present?
        @bios = @category.bios
        @twitter_feeds = @bios.map(&:twitter_handle)
      end

      if @category.events.published.upcoming.present?
        @events = @category.events.published.upcoming.map(&:to_article)
      end
    end

    if ( request.env['PATH_INFO'] =~ /\/\z/ ? request.env['PATH_INFO'] : "#{request.env['PATH_INFO']}/" ) != @story.public_path
      redirect_to @story.public_path and return
    end
    respond_with template: "news/story"
  end
end

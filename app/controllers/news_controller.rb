class NewsController < NewApplicationController
  layout 'new/single'
  respond_to :html, :xml, :rss

  before_filter :get_popular_articles

  PER_PAGE = 11

  def story
    @story = NewsStory.published.find_by_slug!(params[:slug])

    @news_category = @story.category

    content_params = {
      page:         params[:page].to_i,
      per_page:     PER_PAGE
    }

    content_params[:exclude] = @story


    if @category = @story.category
      @featured_articles  = @category.featured_articles
      @content = @category.content(content_params)
      @category_articles = @content.map { |a| a.to_article }
      @events  = @category.events.published.upcoming
    end

    if ( request.env['PATH_INFO'] =~ /\/\z/ ? request.env['PATH_INFO'] : "#{request.env['PATH_INFO']}/" ) != @story.public_path
      redirect_to @story.public_path and return
    end

    respond_with template: "news/story"
  end
end

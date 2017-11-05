class PopularArticlesCell < Cell::ViewModel
  cache :show, expires_in: 12.hours

  def show
    render if articles.try(:any?)
  end

  def asset_path(article)
    article.try(:asset).try(:full).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def side_bar
    if !@options[:popular_articles_viewed] && !@options[:popular_articles_discussed]
      get_popular_articles
    end
    render
  end

  def trio
    render
  end

  def order
    @options[:order] || "1001"
  end

  def articles
    popular_articles_viewed.try(:first, 4)
  end

  def popular_articles_viewed
    if (@options[:popular_articles_viewed] || []).any?
      @options[:popular_articles_viewed].try(:first, 4)
    else
      NewsStory.published.order(public_datetime: :desc).all.limit(4)
    end
  end

  def popular_articles_discussed
    if (@options[:popular_articles_discussed] || []).any?
      @options[:popular_articles_discussed].try(:first, 4)
    else
      NewsStory.published.order(public_datetime: :desc).all.limit(4).reverse
    end
  end

  def get_popular_articles
    # We have to rescue here because Marshal doesn't know about
    # Rails' autoloading. This should be a non-issue in production,
    # but just in case (and for development), we should be safe.
    # This is fixed in Rails 4.
    # https://github.com/rails/rails/issues/8167
    prev_klass = nil

    begin
      @popular_articles_viewed = Cache.read("popular/viewed")
      @popular_articles_discussed = Cache.read("popular/commented");
    rescue ArgumentError => e
      klass = e.message.match(/undefined class\/module (.+)\z/)[1]

      # If we already tried to load this class but couldn't,
      # give up.
      if klass == prev_klass
        warn "Error caught: Couldn't deserialize popular articles: #{e}"
        @popular_articles = nil
        return
      end

      prev_klass = klass
      klass.constantize # Let Rails load it for us.
      retry
    end
  end
end

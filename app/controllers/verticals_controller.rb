class VerticalsController < NewApplicationController
  layout 'new/vertical'

  PER_PAGE = 16

  def politics
    @category = Category.find_by_slug!('politics')
  end

  def education
    @category = Category.find_by_slug!('education')
  end

  def business
    @category = Category.find_by_slug!('money')
  end



  private

  def blog
    @blog ||= @category.blog
  end
  helper_method :blog


  def quotes
    @quotes ||= @category.quotes.published
  end
  helper_method :quotes


  def events
    @events ||= @category.events.published.upcoming
  end
  helper_method :events


  # Get any content with this category, excluding the lead article,
  # and map them to articles
  def vertical_articles
    @category_content ||= begin
      content_params = {
        :page       => params[:page].to_i,
        :per_page   => PER_PAGE
      }

      content_params[:exclude] = [@category.featured_articles.first]

      if @category.featured_blog.present?
        content_params[:exclude].concat(vertical_blog_articles)
      end

      @category.articles(content_params)
    end
  end

  helper_method :vertical_articles


  # Get the featured blog's latest posts
  def vertical_blog_articles
    return unless @category.blog_id.present?

    @blog_articles ||= begin
      content_params = {
        :classes    => [BlogEntry],
        :with       => { blog: @category.blog_id },
        :page       => 1,
        :per_page   => 2
      }

      content_params[:exclude] = @category.featured_articles.first
      @category.articles(content_params)
    end
  end

  helper_method :vertical_blog_articles


  # The business vertical (only) needs Marketplace articles.
  def vertical_marketplace_articles
    @vertical_marketplace_articles ||=
      NewsStory.where(source: 'marketplace')
        .published.first(2).map(&:to_article)
  end

  helper_method :vertical_marketplace_articles
end

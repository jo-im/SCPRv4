module VerticalHandler
  extend ActiveSupport::Concern

  included do
    helper_method :vertical_blog_articles
    helper_method :vertical_articles
  end

  PER_PAGE = 16

  # /politics
  def handle_vertical_politics
    @category   = Category.find_by_slug('politics')
    @blog       = Blog.find_by_slug('politics')
    @quote      = @vertical.quote
    @events     = @category.events.published.upcoming

    render(
      :layout     => 'news/verticals',
      :template   => 'verticals/politics'
    )
  end


  # /education
  def handle_vertical_education
    @category   = Category.find_by_slug('education')
    @blog       = Blog.find_by_slug('education')
    @quotes     = @vertical.quotes.published
    @events     = @vertical.events.published.upcoming

    render(
      :layout     => 'news/verticals',
      :template   => 'verticals/education'
    )
  end


  # /business
  def handle_vertical_business
    @category   = Category.find_by_slug('money')
    @blog       = Blog.find_by_slug('economy')
    @quotes     = @vertical.quotes.published
    @events     = @vertical.events.published.upcoming

    # Business vertical needs to also show Marketplace stories,
    # but we don't have a marketplace blog or anything like that,
    # so we'll just pull in news stories with the "marketplace" source.
    @marketplace_articles = NewsStory.where(source: 'marketplace').published

    render(
      :layout     => 'news/verticals',
      :template   => 'verticals/business'
    )
  end



  private


  # Get any content with this category, excluding the lead article,
  # and map them to articles
  def vertical_articles
    return @category_content if @category_content

    content_params = {
      :page       => params[:page].to_i,
      :per_page   => PER_PAGE
    }

    content_params[:exclude] = [@vertical.featured_articles.first]

    if @blog
      content_params[:exclude].concat(vertical_blog_articles)
    end

    @category_content = @category.articles(content_params)
  end

  # Get the featured blog's latest posts
  def vertical_blog_articles
    return @blog_articles if @blog_articles
    return if !@blog

    content_params = {
      :classes    => [BlogEntry],
      :with       => { blog: @category.blog_id },
      :page       => 1,
      :per_page   => 2
    }

    content_params[:exclude] = @category.featured_articles.first
    @blog_articles = @category.articles(content_params)
  end
end

# Verticals controller gives us manual control over our verticals,
# instead of trying to cram everything into unrelated database columns.
# To enable a vertical, add its slug to Category::VERTICALS

class VerticalsController < NewApplicationController
  layout 'new/vertical'

  PER_PAGE = 16


  # /politics
  def politics
    @category   = Category.find_by_slug!('politics')
    @blog       = Blog.find_by_slug('politics')
    @quotes     = @category.quotes.published
    @events     = @category.events.published.upcoming
  end


  # /education
  def education
    @category   = Category.find_by_slug!('education')
    @blog       = Blog.find_by_slug('education')
    @quotes     = @category.quotes.published
    @events     = @category.events.published.upcoming
  end


  # /business
  def business
    @category   = Category.find_by_slug!('money')
    @blog       = Blog.find_by_slug('economy')
    @quotes     = @category.quotes.published
    @events     = @category.events.published.upcoming

    # Business vertical needs to also show Marketplace stories,
    # but we don't have a marketplace blog or anything like that,
    # so we'll just pull in news stories with the "marketplace" source.
    @marketplace_articles = NewsStory.where(source: 'marketplace').published
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

    content_params[:exclude] = [@category.featured_articles.first]

    if @blog
      content_params[:exclude].concat(vertical_blog_articles)
    end

    @category_content = @category.articles(content_params)
  end

  helper_method :vertical_articles


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

  helper_method :vertical_blog_articles
end

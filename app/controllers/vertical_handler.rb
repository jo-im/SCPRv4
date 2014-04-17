module VerticalHandler
  extend ActiveSupport::Concern

  included do
    helper_method :vertical_blog_articles
    helper_method :vertical_articles
  end

  PER_PAGE = 16

  # /business
  def handle_vertical_business
    load_vertical_associations

    # Business vertical needs to also show Marketplace stories,
    # but we don't have a marketplace blog or anything like that,
    # so we'll just pull in news stories with the "marketplace" source.
    @marketplace_articles = NewsStory.where(source: 'marketplace')
      .published.map(&:to_article)

    render(
      :layout     => 'new/vertical',
      :template   => 'verticals/business'
    )
  end


  def handle_vertical_default
    load_vertical_associations
    template = "verticals/#{@vertical.slug}"

    render(
      :layout   => 'new/vertical',
      :template => template_exists?(template) ? template : 'verticals/default'
    )
  end


  private

  def load_vertical_associations
    @category   = @vertical.category
    @blog       = @vertical.blog
    @quote      = @vertical.quote
    @events     = @category.events.published.upcoming
  end


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

    # We don't have to use @vertical here because @category and
    # @blog were both loaded through @vertical, so we know we're
    # dealing with the correct content.
    # We are using Sphinx instead of a normal AR query because of
    # the exlude. With a normal AR query we'd have to get the
    # vertical's featured articles, then select only the BlogEntry
    # objects, then use their IDs in an exclusion query. It's not
    # any cleaner than below, but it's easier and faster.
    # It's better to use Category anyways, because it's a well-known
    # fact among the newsroom that leaving a category off of your
    # article essentially makes it invisible.
    @blog_articles = @category.articles({
      :classes    => [BlogEntry],
      :with       => { blog: @blog.id },
      :per_page   => 2,
      :exclude    => @vertical.featured_articles.first
    })
  end
end

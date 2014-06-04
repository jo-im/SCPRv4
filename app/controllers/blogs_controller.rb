class BlogsController < ApplicationController
  include Concern::Controller::GetPopularArticles
  layout 'new/single_blog', only: [:entry]

  respond_to :html, :xml, :rss

  before_filter :load_blog, except: [:index, :entry]
  before_filter :get_popular_articles

  PER_PAGE = 11
  #----------

  def index
    @blogs          = Blog.active.order("name")
    @news_blogs     = @blogs.where(is_news: true)
    @non_news_blogs = @blogs.where(is_news: false)
    render layout:    "application"
  end

  #----------

  def show
    # Only want to paginate for HTML response
    @scoped_entries = @blog.entries.published
    @entries = @scoped_entries.page(params[:page]).per(5)

    respond_with @scoped_entries
  end

  #----------

  def entry

    @entry = BlogEntry.published.includes(:blog).find(params[:id])
    @blog = @entry.blog
    content_params = {
      page:       params[:page].to_i,
      per_page:   PER_PAGE
    }

    content_params[:exclude] = @story

    if @category = @entry.category
      @content = @category.content(content_params)
      @category_articles = @content.map { |a| a.to_article }
    end
    @other_blogs = BlogEntry.published.includes(:blog).first(10).map(&:blog).uniq.first(4)
    @previous_blog_entry = BlogEntry.published.where('blog_id = ? AND published_at < ?', @blog.id, @entry.published_at).first
    respond_with template: "blogs/entry"
  end

  #----------

  # Process the form values for Archive and redirect to canonical URL
  def process_archive_select
    year = params[:archive]["date(1i)"].to_i
    month = "%02d" % params[:archive]["date(2i)"].to_i

    redirect_to blog_archive_path(@blog.slug, year, month) and return
  end

  def archive
    date = Date.new(params[:year].to_i, params[:month].to_i)
    @entries = @blog.entries.published.where(
                "published_at >= ? AND published_at < ?", date.beginning_of_month, date.end_of_month
              ).page(params[:page]).per(5)

    datestr = "#{date.strftime("%B")}, #{date.year}"
    @BLOGTITLE_EXTRA = ": #{datestr}"
    @MESSAGE = "There are no blog posts for <b>#{@blog.name}</b> " \
              "for <b>#{datestr}</b>.".html_safe

    render 'show'
  end

  #----------

  private

  def load_blog
    @blog = Blog.includes(:authors).find_by_slug!(params[:blog])
  end
end

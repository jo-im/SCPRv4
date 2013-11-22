class BlogsController < ApplicationController
  before_filter :load_blog, except: [:index, :entry]
  respond_to :html, :xml, :rss

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
    @blog  = @entry.blog
    @asset = @entry.asset if @entry.asset.present?
    @related_articles = @entry.related_content.first(2) unless @entry.related_content.empty?
    @category = @entry.category

    if @category.issues.any?
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
    @popular_articles = Rails.cache.read("popular/viewed").first(3) if Rails.cache.read("popular/viewed").presence
    if @category.featured_articles.any?
      @resources = @category.featured_articles[1..4]
    end
    if @category.bios.any?
      @bios = @category.bios
      @twitter_feeds = @bios.map(&:twitter_handle)
    end
    render layout: "vertical"
  end

  #----------

  def blog_tagged
    @tag = Tag.where(slug: params[:tag]).first!
    @entries = @blog.entries.published.joins(:tags).where(taggit_tag: { slug: @tag.slug }).page(params[:page]).per(5)
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

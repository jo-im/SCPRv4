class IssuesController < ApplicationController
  layout 'vertical'
  respond_to :html, :xml, :rss

  def index
    @issues = Issue.active
    if Rails.cache.read("popular/viewed").presence
      @top_popular_articles = Rails.cache.read("popular/viewed")[0..1]
      @bottom_popular_articles = Rails.cache.read("popular/viewed")[2..3]
    end
  end

  def show
    @issues = Issue.active
    @issue = Issue.active.find_by_slug!(params[:slug])
    @issue_articles = @issue.articles
    @paginated_articles = Kaminari.paginate_array(@issue.articles).page(params[:page]).per(8)
    @article_count = @issue.articles.count
    if Rails.cache.read("popular/viewed").presence
      @top_popular_articles = Rails.cache.read("popular/viewed")[0..1]
      @bottom_popular_articles = Rails.cache.read("popular/viewed")[2..3]
    end
  end
end

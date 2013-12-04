class IssuesController < NewApplicationController
  layout 'new/issues'
  respond_to :html, :xml, :rss

  before_filter :get_popular_articles
  before_filter :get_issues


  def index
  end

  def show
    @issue = Issue.active.find_by_slug!(params[:slug])
    @issue_articles = @issue.articles
    @paginated_articles = Kaminari.paginate_array(@issue.articles).page(params[:page]).per(8)
    @article_count = @issue.articles.count
  end


  private

  def get_issues
    @issues = Issue.active
  end
end

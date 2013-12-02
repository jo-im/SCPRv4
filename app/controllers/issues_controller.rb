class IssuesController < ApplicationController
  layout 'vertical'
  respond_to :html, :xml, :rss

  def index
    @issues = Issue.active
  end

  def show
    @issue = Issue.active.find_by_slug!(params[:slug])
    @articles = @issue.article_issues
  end
end

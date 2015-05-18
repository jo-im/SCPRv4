class IssuesController < ApplicationController
  layout 'new/issues'
  respond_to :html, :xml, :rss

  before_filter :get_popular_articles
  before_filter :get_issues

  PER_PAGE = 8

  def index
  end

  def show
    @tag = Tag.find_by_slug!(params[:slug])
    @articles = @tag.articles( page:params[:page], per_page:PER_PAGE )
  end


  private

  def get_issues
    @tags = Tag.where(is_featured: true).order("title")
  end
end

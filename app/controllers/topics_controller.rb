class TopicsController < ApplicationController
  layout 'new/ronin'
  respond_to :html, :xml, :rss

  before_filter :get_popular_articles
  before_filter :get_topics

  PER_PAGE = 8

  def index
  end

  def show
    @tag = Tag.find_by_slug!(params[:slug])
    @articles = @tag.articles( page:params[:page], per_page:PER_PAGE )
  end


  private

  def get_topics
    @tags = Tag.order("title")
  end
end

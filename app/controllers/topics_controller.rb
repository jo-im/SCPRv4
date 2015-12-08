class TopicsController < ApplicationController
  layout 'new/ronin'
  respond_to :html, :xml, :rss

  PER_PAGE = 8

  def show
    @tag = Tag.find_by_slug!(params[:slug])
    @articles = @tag.articles( page:params[:page], per_page:PER_PAGE )
  end

end

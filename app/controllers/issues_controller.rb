class IssuesController < ApplicationController
  layout 'vertical'
  respond_to :html, :xml, :rss

  def show
    @issue = Issue.active.find_by_slug!(params[:slug])
  end
end

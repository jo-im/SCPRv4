class NewsController < ApplicationController
  layout 'new/single'
  respond_to :html, :xml, :rss

  before_filter :get_popular_articles

  PER_PAGE = 11

  def story
    @story = NewsStory.published.find(params[:id])

    @content_params = {
      page:         params[:page].to_i,
      per_page:     PER_PAGE
    }

    @content_params[:exclude] = @story

    @category = @story.category

    if request.original_fullpath != @story.public_path
      redirect_to @story.public_path and return
    end

    respond_with template: "news/story"
  end
end

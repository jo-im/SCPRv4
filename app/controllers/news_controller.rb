class NewsController < ApplicationController
  # layout 'new/single'
  respond_to :html, :xml, :rss

  PER_PAGE = 11

  include Concern::Controller::Amp

  def story
    @story = NewsStory.published.find(params[:id])

    @content_params = {
      page:         params[:page].to_i,
      per_page:     PER_PAGE
    }

    @content_params[:exclude] = @story

    @category = Rails.cache.fetch("news_stories/#{@story.cache_key}/category") do
        @story.category
    end

    @tags = Rails.cache.fetch("news_stories/#{@story.cache_key}/tags") do
        @story.try(:tags).try(:map, &:title).try(:join, ', ')
    end

    if request.original_fullpath != @story.public_path
      redirect_to @story.public_path and return
    end

    respond_with template: "news/story"
  end

  amplify :story, expose: {'@amp_record' => "@story"}

end

class PodcastsController < ApplicationController
  before_filter :set_headers, only: [:podcast]
  
  def index
    @podcasts = Podcast.where(is_listed: true).order("title")
  end
  
  #----------
  
  def podcast
    @podcast = Podcast.where(slug: params[:slug]).first!    
    @content = @podcast.content
    render_to_string formats: [:xml]
  end

  #----------
  
  protected

  def set_headers
    response.headers["Content-Type"] = 'text/xml'
    
    if request.headers["Range"].present?
      # Fake the headers for iTunes.
      response.headers["Status"]         = "206 Partial Content"
      response.headers["Accept-Ranges"]  = "bytes"
    
      request.headers["Range"].match(/bytes ?= ?(\d+)-(\d+)?/) do |match|        
        rangeStart, rangeEnd        = match[1].to_i, match[2].to_i
        rangeLength                 = (rangeEnd - rangeStart).to_i
        response.headers["Content-Range"]  = "bytes #{rangeStart}-#{rangeEnd == 0 ? "" : rangeEnd}/*"
      end
    end
  end    
end

class FeedsController < ApplicationController
  layout false
  helper InstantArticlesHelper
  def all_news
    response.headers["Content-Type"] = 'text/xml'

    @feed = {
      :title       => "All News | 89.3 KPCC",
      :description => "All news from KPCC's reporters, bloggers and shows."
    }

    # Anything with a news category is eligible
    @content = ContentBase.search({
      :classes    => [NewsStory, ContentShell, BlogEntry, ShowSegment],
      :limit      => 15,
      :with       => { "category.slug" => true }
    })

    xml = render_to_string(action: "feed", formats: :xml)

    render text: xml, format: :xml
  end

  # This is a deprecated method for delivering Take Two segments to the
  # NPR Story API Ingest. It should be removed as soon as NPR begins using the feed
  # generated by the `npr_ingest` method below.
  def take_two
    response.headers["Content-Type"] = 'text/xml'

    take_two = Program.find_by_slug!('take-two')
    @segments = take_two.episodes.published.first.segments.first(2)
    render template: 'feeds/take_two.xml.builder', format: :xml
  end

  # This is a method for sending recent segments from Off-Ramp, The Frame and
  # the latest two segments from the most recently published Take Two episode
  # to the NPR Story API Ingest: https://github.com/npr/lockbox/wiki/Story-API-Ingest
  # This ingest is used specifically to deliver KPCC audio into the NPR One app.
  # Required format is an RSS feed with xml enclosures to ingest audio and images
  def npr_ingest
    response.headers["Content-Type"] = 'text/xml'

    take_two = Program.find_by_slug!('take-two')
    the_frame = Program.find_by_slug!('the-frame')
    offramp = Program.find_by_slug!('offramp')
    @segments = (
      take_two.episodes.published.first.segments.published.first(2) + 
      the_frame.episodes.published.first.segments.published +
      offramp.episodes.published.first.segments.published 
    )
    @segments.sort do |a,b|
      comp = (b.published_at <=> a.published_at)
      comp.zero? ? (a.id <=> b.id) : comp
    end
    render template: 'feeds/npr_ingest.xml.builder', format: :xml
  end
  
  def facebook_ingest
    response.headers["Content-Type"] = 'text/xml'

    @feed = {
      :title       => "Instant Articles | 89.3 KPCC",
      :description => "Instant Articles from KPCC's reporters, bloggers and shows."
    }

    records = NewsStory.published.where(source: "kpcc").order("published_at DESC").limit(15).concat BlogEntry.published.order('published_at DESC').limit(15)
    @content = records.map(&:get_article).sort_by(&:public_datetime).reverse.first(15)

    xml = render_to_string(action: "facebook", formats: :xml)

    render text: xml, format: :xml
  end

end

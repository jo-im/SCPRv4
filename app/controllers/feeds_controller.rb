class FeedsController < ApplicationController
  layout false

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
      :without    => { category: false }
    })

    xml = render_to_string(action: "feed", formats: :xml)

    render text: xml, format: :xml
  end

  # This is a request for sending the latest two segments from the most recently published Take Two episode
  # to an NPR Story API Ingest: https://github.com/npr/lockbox/wiki/Story-API-Ingest
  # Required format is an RSS feed with xml enclosures to ingest audio and and images
  def take_two
    response.headers["Content-Type"] = 'text/xml'

    take_two = Program.find_by_slug!('take-two')
    @segments = take_two.episodes.published.first.segments.first(2)
    render template: 'feeds/take_two.xml.builder', format: :xml
  end
end

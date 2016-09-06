require "core_ext/string"
class IngestFeedController < ApplicationController
  layout false
  helper InstantArticlesHelper
  # This is similar to the feeds controller,
  # but contains some helper method overrides
  # to render a more consistently clean body
  # to support Facebook and Apples' specs.
  before_action :retrieve_content

  def facebook_ingest
    response.headers["Content-Type"] = 'text/xml'

    @feed = {
      :title       => "Instant Articles | 89.3 KPCC",
      :description => "Instant Articles from KPCC's reporters, bloggers and shows."
    }

    xml = render_to_string(template: 'feeds/facebook.xml.builder', formats: :xml)

    render text: xml, format: :xml
  end

  private

  def retrieve_content
    # This is slow, but ElasticSearch wasn't behaving the way I'd 
    # expect when trying to match the bylines of articles to discount
    # non-kpcc articles.
    @content = cache "ingest-feed-controller", skip_digest: true do
      # Cache should be expiring whenever a news story or a blog entry is published or modified(after publish).
      records = NewsStory.published.where(source: "kpcc").order("published_at DESC").limit(15).concat BlogEntry.published.order('published_at DESC').limit(15)
      # records = records.map(&:get_article).sort_by(&:public_datetime).reverse.first(15)
      records = records.sort_by(&:published_at).reverse.first(15)
      records.reject{|r| contains_anchors?(r.body)}
    end
  end

  def contains_anchors? content
    # Facebook doesn't like anchor tags that link to 
    # elements in the body, so this will tell us if 
    # they are included here.

    Nokogiri::HTML::DocumentFragment.parse(content).css("a").each do |a| 
      if (a.attribute("href") || "").to_s.lstrip.match(/^#/)
        return true
      end
    end 
    false
  end
  
end
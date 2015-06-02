module SegmentsHelper
  def timestamp_if_segment_is_legacy published_at, air_date
    if published_at && air_date && air_date >= (published_at + 4.weeks)
      content_tag :footer, class: ["legacy"] do
        content_tag(:span) do
          published_attr = published_at.strftime("%Y-%m-%d")
          nice_published_at = published_at.strftime("%m/%d/%Y")
          content_tag(:span, "Originally published ") +
          content_tag(:time, nice_published_at, datetime: published_at.strftime("%Y-%m-%d"))        
        end
      end
    end
  end
end
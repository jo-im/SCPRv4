# ImportLAistArticles
#
# Reads from LAist entries API, parses it into the correct json shape,
# and stores that into a cache for lists_controller.rb to read later.

require 'net/http'
require 'json'
module Job
  class ImportLaistArticles < Base
    @priority = :mid
    class << self
      def perform
        response = Net::HTTP.get(URI(LAIST_ENTRIES_URL))
        json = JSON.parse(response)
        if !json || !json['items']
          log "Feed is empty. Aborting."
          return false
        end

        log "#{json['items'].size} LAist stories found."

        list_items = []
        json['items'].each_with_index do |item, i|
          next if item["status"] != "Publish" # Just in case API is not honoring the published status
          list_items.push(
            {
              id: "laist_entry_#{i}",
              type: 'news_story',
              title: item['title'],
              short_title: item['title'].truncate(250),
              published_at: format_date(item['date']),
              updated_at: format_date(item['modifiedDate']),
              byline: item['author']['displayName'],
              teaser: item['excerpt'],
              body: item['body'],
              public_url: item['permalink'],
              assets: [find_thumbnail(item['customFields'])],
              audio: [],
              attributions: [],
              tags: [],
            }
          )
        end

        Rails.cache.write(
          LAIST_ENTRIES_CACHE,
          list_items,
          expires_in: LAIST_ENTRIES_CACHE_TTL
        )

        self.log "Imported LAist articles and wrote to cache"
      end

      def format_date(date_str)
        date_str.gsub(/(\-\d\d\:\d\d)/,'.000\1')
      end

      def find_thumbnail(custom_fields)
        custom_fields.each do |field|
          if field['basename'] == 'thumbnail_105'
            return {
              id: 105,
              title: nil,
              caption: "LAist Entry Thumbnail",
              owner: "",
              thumbnail: {
                url: field['value'],
                width: 105,
                height: 105
              }
            }
          end
        end
      end
    end
  end
end


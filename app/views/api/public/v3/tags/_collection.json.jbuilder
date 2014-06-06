json.array! tags do |tag|
 json.partial! api_view_path("tags", "tag"), tag: tag
end

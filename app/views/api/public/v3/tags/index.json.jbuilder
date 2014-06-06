json.partial! api_view_path("shared", "meta")

json.tags do
  json.partial! api_view_path("tags", "collection"), tags: @tags
end

json.partial! api_view_path("shared", "meta")

json.tag do
  json.partial! api_view_path("tags", "tag"), tag: @tag
end

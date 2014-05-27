json.partial! api_view_path("shared", "version")

json.tag do
  json.partial! api_view_path("tags", "tag"), tag: @tag
end

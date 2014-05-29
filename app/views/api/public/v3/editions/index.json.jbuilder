json.partial! api_view_path("shared", "meta")

json.editions do
  json.partial! api_view_path("editions", "collection"), editions: @editions
end

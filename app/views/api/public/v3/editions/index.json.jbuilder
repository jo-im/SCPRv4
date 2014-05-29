json.partial! api_view_path("shared", "header")

json.editions do
  json.partial! api_view_path("editions", "collection"), editions: @editions
end

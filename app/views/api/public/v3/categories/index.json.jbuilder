json.partial! api_view_path("shared", "meta")

json.categories do
  json.partial! api_view_path("categories", "collection"),
    categories: @categories
end

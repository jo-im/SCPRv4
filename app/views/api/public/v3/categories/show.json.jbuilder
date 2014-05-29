json.partial! api_view_path("shared", "meta")

json.category do
  json.partial! api_view_path("categories", "category"), category: @category
end

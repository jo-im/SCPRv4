json.partial! api_view_path("shared", "meta")

json.bucket do
  json.partial! api_view_path("lists", "list"), bucket: @list

  json.articles do
    json.partial! api_view_path("list", "items"),
      articles: @list.items
  end
end

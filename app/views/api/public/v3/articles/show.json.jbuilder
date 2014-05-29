json.partial! api_view_path("shared", "meta")

json.article do
  json.partial! api_view_path("articles", "article"), article: @article
end

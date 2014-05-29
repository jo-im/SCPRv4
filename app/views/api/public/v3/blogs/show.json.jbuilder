json.partial! api_view_path("shared", "header")

json.blog do
  json.partial! api_view_path("blogs", "blog"), blog: @blog
end

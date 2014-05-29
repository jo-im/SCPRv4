json.partial! api_view_path("shared", "meta")

json.blog do
  json.partial! api_view_path("blogs", "blog"), blog: @blog
end

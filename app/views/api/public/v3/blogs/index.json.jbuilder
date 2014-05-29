json.partial! api_view_path("shared", "header")

json.blogs do
  json.partial! api_view_path("blogs", "collection"), blogs: @blogs
end

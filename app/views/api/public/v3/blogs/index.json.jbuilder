json.partial! api_view_path("shared", "meta")

json.blogs do
  json.partial! api_view_path("blogs", "collection"), blogs: @blogs
end

json.partial! api_view_path("shared", "header")

json.buckets do
  json.partial! api_view_path("buckets", "collection"), buckets: @buckets
end

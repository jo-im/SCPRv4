json.meta do
  json.partial! api_view_path("shared", "version")
  json.partial! api_view_path("shared", "status")
end

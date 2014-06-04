json.partial! api_view_path("shared", "meta")

json.error do
  json.message @message
end

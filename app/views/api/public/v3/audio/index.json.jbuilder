json.partial! api_view_path("shared", "meta")

json.audio do
  json.partial! api_view_path("audio", "collection"), audio: @audio
end

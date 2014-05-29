json.partial! api_view_path("shared", "header")

json.audio do
  json.partial! api_view_path("audio", "audio"), audio: @audio
end

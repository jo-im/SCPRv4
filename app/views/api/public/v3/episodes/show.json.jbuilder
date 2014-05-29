json.partial! api_view_path("shared", "header")

json.episode do
  json.partial! api_view_path("episodes", "episode"), episode: @episode
end

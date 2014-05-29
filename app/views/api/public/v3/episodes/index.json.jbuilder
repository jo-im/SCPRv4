json.partial! api_view_path("shared", "header")

json.episodes do
  json.partial! api_view_path("episodes", "collection"), episodes: @episodes
end

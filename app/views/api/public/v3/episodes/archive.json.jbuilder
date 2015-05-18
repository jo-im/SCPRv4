json.partial! api_view_path("shared", "meta")

json.episodes do
  json.partial! api_view_path("episodes", "archive_collection"), episodes: @episodes
end

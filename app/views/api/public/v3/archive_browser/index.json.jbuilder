json.partial! api_view_path("shared", "meta")

json.episodes do
  json.partial! api_view_path("archive_browser", "collection"), episodes: @episodes
end

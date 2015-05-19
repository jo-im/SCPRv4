json.array! episodes do |episode|
  json.partial! api_view_path("archive_browser", "episode"), episode: episode
end

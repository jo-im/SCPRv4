json.array! episodes do |episode|
  json.partial! api_view_path("episodes", "archive_episode"), episode: episode
end

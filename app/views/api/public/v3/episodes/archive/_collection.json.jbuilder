json.array! episodes do |episode|
  json.partial! api_view_path("episodes", "archive", "episode"), episode: episode
end

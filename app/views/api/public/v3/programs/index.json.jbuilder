json.partial! api_view_path("shared", "meta")

json.cache! ['/api/v3/programs', @conditions], expires_in: 15.minutes do
  json.programs do
    json.partial! api_view_path("programs", "collection"), programs: @programs
  end
end

json.partial! api_view_path("shared", "meta")

json.programs do
  json.partial! api_view_path("programs", "collection"), programs: @programs
end

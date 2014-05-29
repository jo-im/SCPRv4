json.partial! api_view_path("shared", "meta")

json.edition do
  json.partial! api_view_path("editions", "edition"), edition: @edition
end

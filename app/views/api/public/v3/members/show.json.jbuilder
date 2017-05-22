json.partial! api_view_path("shared", "meta")

json.member do
  json.partial! api_view_path("members", "member"), member: @member
end

json.partial! api_view_path("shared", "meta")

json.program do
  json.partial! api_view_path("programs", "program"), program: @program
end

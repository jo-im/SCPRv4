json.partial! api_view_path("shared", "meta")

json.alert do
  json.partial! api_view_path("alerts", "alert"), alert: @alert
end

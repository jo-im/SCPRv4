json.partial! api_view_path("shared", "header")

json.alerts do
  json.partial! api_view_path("alerts", "collection"), alerts: @alerts
end

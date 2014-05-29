json.partial! api_view_path("shared", "meta")

json.alerts do
  json.partial! api_view_path("alerts", "collection"), alerts: @alerts
end

json.partial! api_view_path("shared", "header")

json.event do
  json.partial! api_view_path("events", "event"), event: @event
end

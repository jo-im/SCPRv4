json.partial! api_view_path("shared", "meta")

json.event do
  json.partial! api_view_path("events", "event"), event: @event
end

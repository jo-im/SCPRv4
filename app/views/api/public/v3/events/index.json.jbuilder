json.partial! api_view_path("shared", "meta")

json.events do
  json.partial! api_view_path("events", "collection"), events: @events
end

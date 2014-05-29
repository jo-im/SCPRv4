json.partial! api_view_path("shared", "header")

json.events do
  json.partial! api_view_path("events", "collection"), events: @events
end

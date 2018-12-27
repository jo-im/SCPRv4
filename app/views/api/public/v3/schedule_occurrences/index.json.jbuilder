json.partial! api_view_path("shared", "meta")

if @display_pledge_status
  json.pledge_drive @pledge_drive || false
end
json.schedule_occurrences do
  json.partial! api_view_path("schedule_occurrences", "collection"),
    schedule_occurrences: @schedule_occurrences
end

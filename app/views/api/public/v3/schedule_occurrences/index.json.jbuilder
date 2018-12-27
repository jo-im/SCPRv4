json.partial! api_view_path("shared", "meta")

if @display_pledge_status
  json.pledge_drive @pledge_drive || false
end

json.cache! ['/api/v3/schedule', @start_time, @length, @pledge_drive, @display_pledge_status], expires_in: 15.minutes do
  if @display_pledge_status
    json.pledge_drive @pledge_drive || false
  end
  json.schedule_occurrences do
    json.partial! api_view_path("schedule_occurrences", "collection"),
                  schedule_occurrences: @schedule_occurrences
  end
end

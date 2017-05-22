json.partial! api_view_path("shared", "meta")

json.settings do
  @settings.each do |setting|
    json.set! setting.key, setting.value
  end
  if @pledge_drive
    json.pledge_drive do
      json.starts_at @pledge_drive.starts_at
      json.ends_at @pledge_drive.ends_at
    end
  end
end

json.partial! api_view_path("shared", "meta")

json.settings do
  @settings.each do |setting|
    json.set! setting.key, setting.value
  end
end

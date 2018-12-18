json.partial! api_view_path("shared", "meta")

json.cache! ['/api/v3/settings', @context, @pledge_drive], expires_in: 5.minutes do
	json.settings do
		@settings.each do |setting|
			json.set! setting.key, setting.value
		end
	end
end

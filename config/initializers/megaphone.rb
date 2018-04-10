# Support loading config via secrets.yml
if Rails.application.secrets.megaphone.is_a?(Hash)
  Rails.application.secrets.megaphone.each do |k,v|
    Rails.configuration.x.megaphone[k] ||= v
  end
end

$megaphone = MegaphoneClient.new({
  token: Rails.configuration.x.megaphone.token,
  network_id: Rails.configuration.x.megaphone.network_id
})
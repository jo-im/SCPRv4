$megaphone = MegaphoneClient.new({
  token: Rails.application.secrets.megaphone['token'],
  network_id: Rails.application.secrets.megaphone['network_id']
})
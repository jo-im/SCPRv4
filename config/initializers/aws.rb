Aws.config.update({
  region: Rails.application.secrets.api['aws']['region'],
  credentials: Aws::Credentials.new(Rails.application.secrets.api['aws']['access_key_id'], Rails.application.secrets.api['aws']['secret_access_key'])
})
# ENV['AWS_ACCESS_KEY_ID']     = Rails.application.secrets.api['aws']['access_key_id']
# ENV['AWS_SECRET_ACCESS_KEY'] = Rails.application.secrets.api['aws']['secret_access_key']
# ENV['AWS_REGION']            = Rails.application.secrets.api['aws']['region']

Aws.config.update({
  region: Rails.application.secrets.api['aws']['region'],
  credentials: Aws::Credentials.new(Rails.application.secrets.api['aws']['access_key_id'], Rails.application.secrets.api['aws']['secret_access_key'])
})
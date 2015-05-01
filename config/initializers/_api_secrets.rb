if Rails.application.secrets.api
  Rails.application.secrets.api.each do |k,v|
    Rails.configuration.x.api[k] = ActiveSupport::OrderedOptions.new(v)
  end
end

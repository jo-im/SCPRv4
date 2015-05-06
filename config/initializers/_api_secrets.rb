if Rails.application.secrets.api
  Rails.application.secrets.api.each do |k,v|
    Rails.configuration.x.api[k] = Hashie::Mash.new(v)
  end
end

# newsroom from secrets
Rails.configuration.x.newsroom ||= Rails.application.secrets.newsroom

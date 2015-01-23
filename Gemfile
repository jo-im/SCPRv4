source 'https://rubygems.org'

## Core
gem 'rails', "~> 4.0.0"
gem 'mysql2', '~> 0.3.14'
gem 'jquery-rails', '~> 3.1.0'
gem "bcrypt-ruby", "~> 3.1.0"
gem 'secretary-rails'

gem 'elasticsearch'
gem 'elasticsearch-rails'
gem 'elasticsearch-model'
gem 'patron'

gem 'dalli'

## Outpost
gem 'outpost-cms'
gem 'outpost-publishing'
gem 'outpost-asset_host'
gem 'outpost-aggregator'
gem 'outpost-secretary'


## Redis
gem "resque", "~> 1.26.pre.0"
gem 'resque-pool', github:"SCPR/resque-pool"
gem 'redis-rails'
gem 'redis-sentinel'

## Views
gem 'kaminari', '~> 0.15.0'
gem 'select2-rails', '3.4.1'
gem 'twitter-text', "~> 1.5"
gem 'sanitize', "~> 2.0"
gem 'escape_utils', '~> 1.0.1'
gem 'simple_form', "~> 3.0.0"
gem 'jbuilder', '~> 1.5.3'

gem 'embeditor-rails', '~> 2.0.1'


## Utility
gem "carrierwave", "~> 0.6"
gem "ruby-mp3info", '~> 0.8.2', require: 'mp3info'
gem "ice_cube", "~> 0.11.0"
gem "recaptcha", require: "recaptcha/rails"
gem "yajl-ruby" # Faster JSON parsing
gem "rack-utf8_sanitizer"
gem "rufus-scheduler"


## HTTP
gem "faraday", "~> 0.8"
gem "faraday_middleware", "~> 0.8"
gem "hashie", "~> 1.2.0"


## APIs
gem "twitter", "~> 4.1"
gem "oauth2", "~> 0.8"
gem 'postmark-rails', "~> 0.6.0"
gem 'newrelic_rpm', '~> 3.7'
gem 'parse-ruby-client', github: "sheerun/parse-ruby-client", ref: "a4eb5618c8167e88857b449cd522b23a8b0c02e9"
gem 'pmp', '0.4.0'
gem 'npr', '~> 2.0'
gem 'asset_host_client', '~> 1.2'
gem 'audio_vision', '~> 1.0'
gem 'tinder'
gem 'appsignal'

## Assets
gem "eco", "~> 1.0"
gem 'sass-rails', "=5.0.0beta1"
gem 'bootstrap-sass', '~> 2.2'
gem 'coffee-rails', "~> 4.0.0"
gem 'uglifier', '>= 1.3'

group :development do
  gem 'pry'
end


group :development, :staging do
  gem "dbsync", '>= 1.0.0.beta4'
end


group :test, :development do
  gem "rspec-rails", "~> 2.14.0"
  gem 'rb-fsevent', '~> 0.9'
  gem 'launchy'
  gem 'guard', '~> 1.5'
  gem 'guard-resque'
  gem 'guard-rspec'
  gem 'ruby-prof'
end


group :test do
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara', "~> 2.0"
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'test_after_commit'
  gem 'elasticsearch-extensions'
end

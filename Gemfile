source 'https://rubygems.org'

## Core
gem 'rails', "~> 3.2"
gem 'mysql2'
gem 'jquery-rails'
gem "bcrypt-ruby", "~> 3.0.0"

gem 'thinking-sphinx', '~> 3.0.5'
# https://github.com/pat/riddle/pull/75
gem 'riddle', github: 'bricker/riddle', branch: 'fix-empty-array-filter'

## Outpost
gem 'outpost-cms', github: 'SCPR/outpost'
#gem 'outpost-cms', path: "#{ENV['PROJECT_HOME']}/outpost"

gem 'outpost-publishing', github: "SCPR/outpost-publishing"
#gem 'outpost-publishing', path: "#{ENV['PROJECT_HOME']}/outpost-publishing"

gem 'outpost-asset_host', github: "SCPR/outpost-asset_host"
#gem 'outpost-asset_host', path: "#{ENV['PROJECT_HOME']}/outpost-asset_host"

gem 'outpost-aggregator', github: "SCPR/outpost-aggregator"
#gem 'outpost-aggregator', path: "#{ENV['PROJECT_HOME']}/outpost-aggregator"

gem 'secretary-rails', github: "SCPR/secretary-rails"
# gem 'secretary-rails', path: "#{ENV['PROJECT_HOME']}/secretary-rails"


## Cache
gem 'redis-content-store', github: "SCPR/redis-content-store"
# gem 'redis-content-store', path: "#{ENV['PROJECT_HOME']}/redis-content-store"
gem "resque", "~> 1.26.pre.0"


## Views
gem 'kaminari', github: "amatsuda/kaminari"
gem 'ckeditor_rails', '~> 4.3.0'
gem 'select2-rails', '3.4.1'
gem 'twitter-text', "~> 1.5"
gem 'sanitize', "~> 2.0"
gem 'escape_utils', '~> 1.0.1'
gem 'simple_form', "~> 2.0"
gem 'jbuilder'
gem 'embeditor-rails', github: 'SCPR/embeditor-rails'
#gem 'embeditor-rails', path: "#{ENV['PROJECT_HOME']}/embeditor-rails"


## Utility
gem "carrierwave", "~> 0.6"
gem "ruby-mp3info", require: 'mp3info'
gem "ice_cube", "~> 0.11.0"


## HTTP
gem "faraday", "~> 0.8"
gem "faraday_middleware", "~> 0.8"
gem "hashie", "~> 1.2.0"


## APIs
gem "twitter", "~> 4.1"
gem "oauth2", "~> 0.8"
gem 'simple_postmark', "~> 0.5"
gem 'newrelic_rpm'
gem 'parse-ruby-client', '~> 0.1.15'
gem 'pmp', '~> 0.2.4'
gem 'npr', github: "bricker/npr"
#gem 'npr', path: "#{ENV['PROJECT_HOME']}/npr"
gem 'asset_host_client', github: "SCPR/asset_host_client"
#gem 'asset_host_client', path: "#{ENV['PROJECT_HOME']}/asset_host_client"
gem 'audio_vision', github: 'SCPR/audio_vision-ruby'
#gem 'audio_vision', path: "#{ENV['PROJECT_HOME']}/audio_vision-ruby"

group :assets do
  gem "eco", "~> 1.0"
  gem 'sass-rails', "~> 3.2"
  gem 'bootstrap-sass', '~> 2.2'
  gem "compass-rails"
  gem 'coffee-rails', "~> 3.2"
  gem 'uglifier', '>= 1.3'
end


group :development do
  gem 'capistrano', '~> 2.0'
  gem 'pry'
end


group :development, :staging do
  gem "dbsync", github: "bricker/dbsync"
  #gem 'dbsync', path: "#{ENV['PROJECT_HOME']}/dbsync"
end


group :test, :development do
  gem "rspec-rails", "~> 2.12"
  gem 'rb-fsevent', '~> 0.9'
  gem 'launchy'
  gem 'guard', '~> 1.5'
  gem 'guard-resque'
  gem 'guard-rspec'
  gem 'rb-readline', '~> 0.4.2'
end


group :test do
  gem 'simplecov', require: false
  gem "sqlite3"
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara', "~> 2.0"
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'test_after_commit'
end

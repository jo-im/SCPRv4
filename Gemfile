source :rubygems

## Core
gem 'rails', "~> 3.2"
gem 'mysql2'
gem 'jquery-rails'
gem "bcrypt-ruby", "~> 3.0"
gem 'thinking-sphinx', '~> 2.0', require: "thinking_sphinx"


## Cache
gem 'redis-content-store', github: "SCPR/redis-content-store"
# gem 'redis-content-store', :path => "/Users/bryan/projects/redis-content-store"
gem "resque", "~> 1.20"


## Views
gem 'kaminari', github: "amatsuda/kaminari"
gem 'tinymce-rails', "~> 3.5"
gem 'twitter-text', "~> 1.5"
gem 'sanitize', "~> 2.0"
gem 'simple_form', "~> 2.0"


## Utility
gem "diffy", "~> 2.0"
gem "carrierwave", "~> 0.6"
gem "ruby-mp3info", require: 'mp3info'


## HTTP
gem "faraday", "~> 0.8"
gem "faraday_middleware", "~> 0.8"
gem "hashie", "~> 1.2.0"
gem "feedzirra", github: "pauldix/feedzirra"


## APIs
gem "twitter", "~> 4.1"
gem "oauth2", "~> 0.8"
gem 'simple_postmark', "~> 0.5"
gem 'newrelic_rpm'
gem 'npr', github: "bricker/npr"
#gem 'npr', path: "/Users/bricker/websites/kpcc/gems/npr"


## Assets
group :assets do
  gem "eco", "~> 1.0"
  gem 'sass-rails', "~> 3.2"
  gem 'bootstrap-sass', '~> 2.2'
  gem "compass-rails"
  gem 'coffee-rails', "~> 3.2"
  gem 'uglifier', '>= 1.3'
end


## Development Only
group :development do
  gem 'capistrano'
end


## Development, Staging
group :development, :staging do
  gem "dbsync"
end


## Test, Development
group :test, :development do
  gem "rspec-rails", "2.12.0"
  gem 'rb-fsevent', '~> 0.9'
  gem 'launchy'
  gem 'jasminerice'
  gem 'rb-readline'
  gem 'guard', '~> 1.5'
  gem 'guard-rspec'
  gem 'guard-jasmine'
end


## Test Only
group :test do
  gem 'simplecov', require: false
  gem "sqlite3"
  gem 'factory_girl_rails', "~> 4.1"
  gem 'database_cleaner'
  gem 'capybara', "~> 2.0"
  gem 'shoulda-matchers'
  gem 'fakeweb'
  gem 'chronic', "~> 0.8"
end

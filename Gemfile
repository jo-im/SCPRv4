source 'http://rubygems.org'

gem 'rails', "~> 3.2.3"
gem 'mysql2'

#gem 'redis-content-store', :path => "/Users/bryan/projects/redis-content-store"
gem 'redis-content-store', :git => "git://github.com/SCPR/redis-content-store.git", :ref => "dcb7843b10afc68a85c105fd58eaa76cf71e250f"

gem 'jquery-rails'
gem 'will_paginate'
gem 'capistrano'
gem 'disqussion', :git => "git://github.com/SCPR/disqussion.git"
#gem 'disqussion', :path => "/Users/eric/projects/forks/disqussion"
gem 'thinking-sphinx', '~> 2.0.10'
gem 'therubyracer'
gem 'newrelic_rpm'

gem "faraday", "0.7.6"
gem "faraday_middleware"

gem "ruby-mp3info"
gem "feedzirra", git: "git://github.com/pauldix/feedzirra.git"
gem "twitter"
gem 'twitter-text'
gem "oauth2"
gem 'simple_form'
gem 'chronic'

gem "bcrypt-ruby", "~> 3.0.0"

group :assets do
  gem "eco"
  gem "sass", branch: 'master', git: 'git://github.com/nex3/sass.git'
  gem 'sass-rails'
  gem 'bootstrap-sass'
  gem "compass-rails"
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'oily_png'
end

group :test, :development do
	gem "rspec-rails"
	gem 'guard-rspec'
	gem 'guard-cucumber'
	gem 'launchy'
end

group :test do
  gem "cucumber-rails", require: false
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'shoulda-matchers'
  gem 'fakeweb'
end

group :worker do
  gem 'rubypython'
end

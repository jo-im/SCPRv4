source 'http://rubygems.org'

## Core
gem 'rails', '~> 4.2', '>= 4.2.7'
gem 'rake', '< 11.0'
gem 'responders', '~> 2.0'
gem 'mysql2', '~> 0.3.18'
gem 'jquery-rails', '~> 3.1.0'
gem "bcrypt-ruby", "~> 3.1.0"
gem 'secretary-rails', "~> 2.0.1"

gem 'elasticsearch'
gem 'elasticsearch-rails'
gem 'elasticsearch-model'
gem 'patron'
gem 'render_anywhere'

gem 'dalli'

## Outpost
gem 'outpost-cms', github: "SCPR/outpost", tag: "v0.3.1"
gem 'outpost-publishing'
gem 'outpost-asset_host', github: "SCPR/outpost-asset_host"
gem 'outpost-aggregator', github: "SCPR/outpost-aggregator", tag: "v2.1.0"
gem 'outpost-secretary', github:"SCPR/outpost-secretary", tag:"v0.1.1"


## Redis
gem "resque", "~> 1.26.pre.0"
gem 'resque-pool', github:"SCPR/resque-pool"
gem 'redis-rails'
gem 'resque_solo'

## Views
gem 'kaminari', '~> 0.15.0'
gem 'select2-rails', '3.4.1'
gem 'twitter-text', "~> 1.5"
gem 'sanitize', "~> 2.0"
gem 'escape_utils', '~> 1.0.1'
gem 'simple_form', "~> 3.1.0"
gem 'jbuilder', '~> 1.5.3'
gem 'html-pipeline', require: "html/pipeline"
gem 'cells-rails'
gem 'cells-erb'
gem 'cells-handlebars', github: 'PeerStreet/cells-handlebars'
gem 'cells-capture'


## Utility
gem "carrierwave", "~> 0.6"
gem "ruby-mp3info", '~> 0.8.10', require: 'mp3info'
gem "ice_cube", "~> 0.11.0"
gem 'recaptcha', '~> 0.4.0'
gem 'yajl-ruby', '~> 1.3', '>= 1.3.1' # Faster JSON parsing
gem "rack-utf8_sanitizer"
gem "rufus-scheduler"
gem 'rubyzip', '~> 1.2', require: false
gem 'pygments.rb', '~> 1.1'
gem 'reverse_markdown', require: false
gem 'htmlentities', require: false
gem 'honeybadger', '~> 2.0'
gem 'oink', '~> 0.10.1'
gem 'resque-scheduler', '~> 4.0'

## HTTP
gem "faraday", "~> 0.8"
gem "faraday_middleware", "~> 0.8"
gem "hashie", "~> 1.2.0"
gem "rest-client"
gem "open_uri_redirections"


## APIs
gem "twitter", "~> 4.1"
gem "oauth2", "~> 0.8"
gem 'postmark-rails', "~> 0.6.0"
gem 'newrelic_rpm', '~> 4.0', '>= 4.0.0.332'
gem 'parse-ruby-client', github: "sheerun/parse-ruby-client", ref: "a4eb5618c8167e88857b449cd522b23a8b0c02e9"
gem 'farse-ruby-client', github: "scpr/parse-ruby-client"
gem 'pmp', '0.5.6'
#gem "npr", path:"../npr"
gem 'npr', '~> 3.0', github:"scpr/npr"
gem 'asset_host_client', github:"scpr/asset_host_client", tag:"v2.1.3"
gem 'audio_vision', '~> 1.0'
gem 'slack-notifier'
gem 'aws-sdk', '~> 2'
gem 'one_signal'
gem 'megaphone_client', github: "scpr/megaphone_client"

## Assets
gem "eco", "~> 1.0"
gem 'sass-rails', "=5.0.0beta1"
gem 'bootstrap-sass', '~> 2.2'
gem 'coffee-rails', "~> 4.0.0"
gem 'uglifier', '>= 1.3'
gem "browserify-rails"
gem "autoprefixer-rails"

group :development do
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'browser_sync_rails'
end

group :test, :development do
  gem "rspec-rails", "~> 3.2.1"
  gem 'rspec-cells', '~> 0.3.3'
  gem 'rb-fsevent', '~> 0.9'
  gem 'launchy'
  gem 'guard', '~> 1.5'
  gem 'guard-resque'
  gem 'guard-rspec'
  gem 'ruby-prof'
  gem 'byebug'
end


group :test do
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara', "~> 2.0"
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'test_after_commit'
  gem 'elasticsearch-extensions'
  gem 'rspec_junit_formatter'
  gem 'timecop'
  gem 'faker'
end

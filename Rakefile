#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# for some reason it otherwise tends to default to 'test'
ENV['RAILS_ENV'] ||= "development"

require File.expand_path('../config/application', __FILE__)
require 'resque/tasks'

Scprv4::Application.load_tasks

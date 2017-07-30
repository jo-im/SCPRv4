#!/bin/sh

bundle config build.nokogiri --use-system-libraries
bundle install
npm install
rm tmp/pids/server.pid
bin/rails s -b 0.0.0.0


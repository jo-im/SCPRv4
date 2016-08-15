# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

require "papi-client/helpers"
require "thor"
require "yaml"

module PapiClient
    class PapiThor < Thor
        include PapiClient::Helpers

        protected

        def self.start(given_args = ARGV, config = {})
            path = File.expand_path("~/.papi")
            if File.exists?(path)
                yaml = ::YAML::load_file(path) || {}
                ["endpoint", "key", "secret", "channel_id"].each do |o|
                    unless yaml[o].nil?
                        given_args += ["--#{o}", yaml[o]] unless given_args.join(" ") =~ /--#{o}/
                    end
                end
            end
            super(given_args, config)
        end
    end
end

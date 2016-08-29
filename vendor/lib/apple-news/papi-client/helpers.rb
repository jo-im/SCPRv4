# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

require "papi-client/api"
require "pygments"

module PapiClient
    module Helpers
        def client
            PapiClient::API.new(to_kwargs(options, :endpoint, :key, :secret, :verify_ssl))
        rescue MissingArgumentError => e
            abort "No value provided for required option '--#{e.arg}'"
        end

        def output
            response = yield
            begin
                print_header(response) if options[:verbose]
                unless response.to_s.empty?
                    json = JSON.pretty_generate(JSON.parse(response.to_s))
                    json = colorize(json) if options[:color]
                    puts json
                end
            rescue JSON::ParserError => e
                puts response.to_s
            rescue Exception => e
                puts "#{$!.class}: #{$!}\n\tfrom #{$@.join("\n\tfrom ")}"
            end
        end

        private

        def print_header(response)
            puts "HTTP/1.1 #{response.code} #{response.net_http_res.msg}"
            response.raw_headers.each do |name, values|
                values.each do |value|
                    puts "#{name}: #{value}"
                end
            end
            puts
        end

        def colorize(json)
            Pygments.highlight(json, :formatter => "terminal", :lexer => "javascript", :options => { :encoding => "utf-8" })
        end

        def to_kwargs(hash, *keys)
            hash.reduce({}) do |memo, (k, v)|
                memo[k.to_sym] = v if keys.include?(k.to_sym)
                memo
            end
        end
    end
end

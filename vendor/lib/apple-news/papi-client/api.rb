# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

require "rest-client"
require "time"
require "pygments"
require "base64"
require "openssl"
require "securerandom"
require "cgi"

RestClient.add_before_execution_proc do |req, params|
    Signer.sign_request(req, params)
end

module Signer
    DIGEST = OpenSSL::Digest.new("sha256")

    class << self
        attr_accessor :key, :secret

        def sign_request(req, params)
            date = Time.now.utc.iso8601
            url = params[:url] || params[:path]
            canonical_request = req.method + url + date
            if params[:payload]
                canonical_request += req["Content-Type"] + params[:payload]
            end
            signature = OpenSSL::HMAC.digest(DIGEST, secret, canonical_request)
            encoded_signature = Base64.encode64(signature).strip
            req["Authorization"] = "HHMAC; key=\"#{key}\"; signature=\"#{encoded_signature}\"; date=\"#{date}\""
        end
    end
end

module PapiClient
    class API
        def initialize(endpoint: nil , key: nil, secret: nil, verify_ssl: true)
            raise MissingArgumentError.new(:endpoint) if endpoint.nil?
            raise MissingArgumentError.new(:key) if key.nil?
            raise MissingArgumentError.new(:secret) if secret.nil?
            if verify_ssl
                @resource = RestClient::Resource.new(endpoint, :timeout => 300)
            else
                warn "WARNING: Not verifying server SSL certificate. A middleman could intercept and read your traffic, and make limited replay attacks."
                @resource = RestClient::Resource.new(endpoint, :timeout => 300, :verify_ssl => OpenSSL::SSL::VERIFY_NONE)
            end
            @key = key
            @secret = Base64.decode64(secret)
            @endpoint = endpoint
        end

        def get_channel(id)
            request(:get, "/channels/#{id}")
        end

        def get_article(id)
            request(:get, "/articles/#{id}")
        end

        def delete_article(id)
            request(:delete, "/articles/#{id}")
        end

        def get_section(id)
            request(:get, "/sections/#{id}")
        end

        def list_sections(id)
            request(:get, "/channels/#{id}/sections")
        end

        def publish_article(options, article_dir)
            body, boundary = create_body(nil, options, article_dir)
            request(:post, "/channels/#{options["channel_id"]}/articles", body, "multipart/form-data; boundary=#{boundary}")
        end

        def update_article(article_id, revision, options)
            body, boundary = create_body(revision, options, options["article_dir"], require_article: false)
            request(:post, "/articles/#{article_id}", body, "multipart/form-data; boundary=#{boundary}")
        end

        def search_articles(channel_id, page_token, page_size, from_date, to_date, sort_dir, section_id)
            if section_id.nil?
                path = "/channels/#{channel_id}/articles?"
            else
                path = "/sections/#{section_id}/articles?"
            end
            path += "pageToken=#{CGI::escape(page_token)}&" unless page_token.nil?
            path += "pageSize=#{CGI::escape(page_size)}&" unless page_size.nil?
            path += "fromDate=#{CGI::escape(from_date)}&" unless from_date.nil?
            path += "toDate=#{CGI::escape(to_date)}&" unless to_date.nil?
            path += "sortDir=#{CGI::escape(sort_dir)}&" unless sort_dir.nil?
            path.gsub!(/(&|\?)\z/, "")
            request(:get, path)
        end

        private

        def create_body(revision, options, article_dir, require_article: true)
            # KPCC - changed this to allow a different input filename
            file_name = options[:file_name] || 'article.json'
            boundary = SecureRandom.hex
            unless article_dir.nil?
                article_dir = File.expand_path(article_dir)
                article_file = File.join(article_dir, file_name)

                unless File.exists?(article_file)
                    if require_article
                        raise ArgumentError.new("Directory must contain a file named '#{file_name}'")
                    else
                        article_file = nil
                    end
                end

                dir = File.expand_path(article_dir)
            end

            body = ""

            metadata_body = create_metadata(revision, options, @endpoint)
            body += part(boundary, "application/json", "metadata", metadata_body)

            unless article_dir.nil?
                unless article_file.nil?
                    article_txt = File.read(article_file)
                    body += part(boundary, "application/json", "article.json", article_txt)
                end
                body += create_parts_for_files(boundary, dir)
            end

            body += "--#{boundary}--"

            [body, boundary]
        end

        def request(method, path, body=nil, content_type="application/json")
            Signer.key = @key
            Signer.secret = @secret
            begin
                if body
                    @resource[path].send(method, body, "Content-Type" => content_type)
                else
                    @resource[path].send(method)
                end
            rescue RestClient::ExceptionWithResponse => e
                e.response
            end
        end

        def create_parts_for_files(boundary, dir)
            Dir.entries(dir).select { |f| f =~ /(\.jpg|\.jpeg|\.png|\.gif)$/i }.map do |filename|
                next unless File.file?(File.join(dir, filename))
                mime_types = MIME::Types.of(filename)
                raise Exception.new("No MIME types detected for #{filename}") if mime_types.nil? or mime_types.empty?
                part(boundary, mime_types.first.content_type, filename, File.read(File.join(dir, filename)))
            end.join("")
        end

        def part(boundary, type, name, byte_string)
            part = "--#{boundary}\r\n"
            part += "Content-Type: #{type}\r\n"
            part += "Content-Disposition: form-data; name=\"#{name}\"; filename=\"#{name}\"; size=#{byte_string.bytesize}\r\n"
            part += "\r\n"
            part += byte_string
            part += "\r\n"
        end

        def create_metadata(revision, options, endpoint)
            metadata = {:data => {}}

            unless revision.nil?
                metadata[:data][:revision] = revision
            end

            unless options[:is_sponsored].nil?
                metadata[:data][:isSponsored] = options[:is_sponsored]
            end

            unless options[:is_preview].nil?
                metadata[:data][:isPreview] = options[:is_preview]
            end

            unless options[:maturity_rating].nil?
               metadata[:data][:maturityRating] = options[:maturity_rating]
            end

            unless options[:section_ids].nil?
                metadata[:data][:links] ||= {}
                metadata[:data][:links][:sections] = options[:section_ids].split(',').map { |s| "#{endpoint}/sections/#{s}" }
            end

            metadata.to_json
        end
    end

    class MissingArgumentError < ArgumentError
        attr_reader :arg

        def initialize(arg)
            @arg = arg
            super("Missing argument: #{arg.to_s}")
        end
    end
end

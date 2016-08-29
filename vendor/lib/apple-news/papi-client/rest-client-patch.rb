# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

module RestClient
    module Payload
        class Multipart < Base
            def create_file_field(s, k, v)
                begin
                    s.write("Content-Disposition: form-data;")
                    s.write(" name=\"#{k}\";") unless (k.nil? || k=='')
                    s.write(" filename=\"#{v.respond_to?(:original_filename) ? v.original_filename : File.basename(v.path)}\";")
                    s.write(" size=#{v.respond_to?(:size) ? v.size : File.size(v.path)}#{EOL}")
                    s.write("Content-Type: #{v.respond_to?(:content_type) ? v.content_type : mime_for(v.path)}#{EOL}")
                    s.write(EOL)
                    while data = v.read(8124)
                        s.write(data)
                    end
                ensure
                    v.close if v.respond_to?(:close)
                end
            end

            def to_s
                str = read
                @stream.seek(0)
                str
            end
        end
    end
end
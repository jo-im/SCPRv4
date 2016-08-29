# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

require "papi-client/papi-thor"

module PapiClient
    class Section < PapiThor
        desc "get SECTION_ID", "Get section metadata"
        def get(id)
            output { client.get_section(id) }
        end

        desc "list", "List all sections for your channel"
        def list
            output { client.list_sections(options[:channel_id]) }
        end
    end
end

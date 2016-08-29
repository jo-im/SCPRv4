# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

require "papi-client/papi-thor"

module PapiClient
    class Channel < PapiThor
        desc "get", "Get channel metadata"
        def get
            output { client.get_channel(options[:channel_id]) }
        end
    end
end

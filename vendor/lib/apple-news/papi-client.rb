# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

require "papi-client/channel"
require "papi-client/article"
require "papi-client/section"
require "papi-client/papi-thor"

module PapiClient
    class CLI < PapiThor
        class_option :endpoint, type: :string
        class_option :key, type: :string
        class_option :secret, type: :string
        class_option :channel_id, type: :string
        class_option :verbose, type: :boolean
        class_option :color, type: :boolean, default: true
        class_option :verify_ssl, type: :boolean, default: true

        desc "channel ACTION", "Interact with Channel resources"
        subcommand "channel", PapiClient::Channel

        desc "article ACTION", "Interact with Article resources"
        subcommand "article", PapiClient::Article

        desc "section ACTION", "Interact with Section resources"
        subcommand "section", PapiClient::Section
    end
end

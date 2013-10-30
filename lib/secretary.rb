require "secretary/config"
require 'secretary/errors'
require 'diffy'

module Secretary
  extend ActiveSupport::Autoload

  class << self
    attr_writer :config
    def config
      @config || Secretary::Config.configure
    end

    def versioned_models
      @versioned_models ||= []
    end
  end

  autoload :HasSecretary
  autoload :Version
  autoload :VersionedAttributes
end

ActiveSupport.on_load(:active_record) do
  extend Secretary::HasSecretary
  extend Secretary::TracksAssociation
  include Secretary::VersionedAttributes
end

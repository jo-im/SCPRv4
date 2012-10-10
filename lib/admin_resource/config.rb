##
# AdminResource::Config
# Define configuration for AdminResource
#
module AdminResource
  class Config
    DEFAULTS = {
      title_attributes: [:name, :title]
    }
    
    # Pass a block to this method to define the configuration
    # If no block is passed, config will be defaults
    def self.configure
      config = new
      yield config if block_given?
      AdminResource.config = config
    end
    
    #------------------
    # An array of models that should show up
    attr_writer :registered_models
    def registered_models
      @registered_models || []
    end
    
    #--------------
    # A hash of groups of models, for navigation
    attr_writer :nav_groups
    def nav_groups
      @nav_groups || {}
    end
    
    #--------------
    # Which attributes to look at for `to_title`
    attr_writer :title_attributes
    def title_attributes
      (@title_attributes ||= DEFAULTS[:title_attributes]) | [:simple_title]
    end
  end
end

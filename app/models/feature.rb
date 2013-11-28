class Feature
  DEFAULT_ASSET_DISPLAY = "photo"

  class << self
    # Retrieve the correct Feature based on ID or key
    # Features[:slideshow] # => 
    def find_by_id(id)
      FEATURES.find { |f| f.id == id }
    end

    def find_by_key(key)
      FEATURES.find { |f| f.key == key }
    end
  end


  attr_accessor \
    :id,
    :key
    :name,
    :asset_display


  def initialize(attributes={})
    @id             = attributes[:id]
    @key            = attributes[:key]
    @name           = attributes[:name]
    @asset_display  = attributes[:asset_display]
  end
end

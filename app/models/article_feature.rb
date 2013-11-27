class ArticleFeature
  DEFAULT_ASSET_DISPLAY = "photo"

  class << self
    # All the features created.
    def collection
      @collection ||= Array.new
    end

    # Retrieve the correct Feature based on ID or key
    # Features[:slideshow] # => 
    def find_by_id(id)
      collection.find { |f| f.id == id }
    end

    def find_by_key(key)
      collection.find { |f| f.key == key }
    end
  end


  attr_reader \
    :id,
    :key,
    :name,
    :asset_display


  def initialize(attributes={})
    @id             = attributes[:id]
    @key            = attributes[:key]
    @name           = attributes[:name]
    @asset_display  = attributes[:asset_display]

    self.class.collection << self
  end

  # To check equality of a feature.
  # Example: self.feature == :slideshow
  def ==(value)
    case value
    when ArticleFeature
      value.id == self.id
    when Integer
      value == self.id
    when Symbol
      value == self.key
    else
      false
    end
  end
end

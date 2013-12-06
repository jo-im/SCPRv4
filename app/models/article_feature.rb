# All attributes are required. There are no defaults.
# Yes, I realize there are big capital letters right below
# this that specify a default.
class ArticleFeature
  DEFAULT_ASSET_DISPLAY = "photo"

  class << self
    def select_collection
      collection.map { |f| [f.name, f.id] }
    end

    # All the features created.
    # Note: This used to be a memoized array which was pushed to
    # in this class's initialize method, but it can't work that
    # way in development with Rails' auto-loading modules, so
    # instead we're just storing it in a dumb ol' constant.
    def collection
      @collection ||= FEATURES
    end

    attr_writer :collection

    # Retrieve the correct Feature based on ID or key
    # Features[:slideshow] # => 
    def find_by_id(id)
      collection.find { |f| f.id == id.to_i }
    end

    def find_by_key(key)
      collection.find { |f| f.key == key.to_sym }
    end
  end


  attr_reader \
    :id,
    :key,
    :name,
    :asset_display


  def initialize(attributes={})
    @id             = attributes[:id].to_i
    @key            = attributes[:key].to_sym
    @name           = attributes[:name].to_s
    @asset_display  = attributes[:asset_display].to_s
  end

  # To check equality of a feature.
  # Example: self.feature == :slideshow
  def ==(value)
    case value
    when ArticleFeature
      value.id == self.id
    when Integer
      value == self.id
    when Symbol, String
      value.to_sym == self.key
    else
      false
    end
  end
end

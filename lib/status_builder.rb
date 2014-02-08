# Build yo statuses

module StatusBuilder
  extend ActiveSupport::Concern

  module ClassMethods
    # Activate the status methods for a class.
    def has_status
      extend ClassMethodsOnActivation
      include InstanceMethodsOnActivation
    end
  end


  module ClassMethodsOnActivation
    # This class's statuses mapped for a select collection
    # Returns Array
    def status_select_collection
      self.statuses.map { |s| [s.text, s.id] }
    end


    # A collection of this class's statuses
    # Returns Array
    def statuses
      @statuses ||= []
    end


    # Find statuses by their keys and return the ids
    #
    # Arguments
    # * keys - (Symbol) A variable number of keys to look up
    #
    # Example
    #
    #   Article.status_ids(:live, :draft) #=> [5, 0]
    #
    # Returns Array
    def status_ids(*keys)
      ids = []

      keys.each do |key|
        if id = status_id(key)
          ids << id
        end
      end

      ids
    end


    # Find a status by its key and return the id
    #
    # Arguments
    # * key - (Symbol) The key to look up.
    #
    # Example
    #
    #   Article.status_id(:live) #=> 5
    #
    # Returns Integer or nil
    def status_id(key)
      self.find_status_by_key(key).try(:id)
    end


    # Find status with ambiguous argument.
    #
    # Arguemnts
    # * status - (Integer, Symbol, or Status) The status to lookup
    #
    # Example
    #
    #   Article.find_status(1)      #=> #<Status ...>
    #   Article.find_status(status) #=> #<Status ...>
    #   Article.find_status(:live)  #=> #<Status ...>
    #
    # Returns Status
    def find_status(status)
      case status
      when Integer
        find_status_by_id(id)
      when Symbol
        find_status_by_key(status)
      when Status
        status
      end
    end


    # Find a status in this collection by its id
    #
    # Arguments
    # * id - (Integer) The id to look up.
    #
    # Example
    #
    #   Article.find_status_by_id(0) #=> #<Status ...>
    #
    # Returns Status or nil
    def find_status_by_id(id)
      self.statuses.find { |s| s.id == id }
    end


    # Find a status in this collection by its key
    #
    # Arguments
    # * key - (Symbol) The key to look up.
    #
    # Example
    #
    #   Article.find_status_by_key(:draft) #=> #<Status ...>
    #
    # Returns Status or nil
    def find_status_by_key(key)
      self.statuses.find { |s| s.key == key }
    end


    # Find all statuses in this collection with the given type
    #
    # Arguments
    # * type - (Symbol) The type to look up.
    #
    # Example
    #
    #   Article.find_status_by_type(:published) #=> [#<Status ...>]
    #
    # Returns Array
    def find_status_by_type(type)
      self.statuses.select { |s| s.type == type }
    end


    # Get the status text for a given status
    #
    # Arguments
    # * status - (Integer, Symbol, or Status) The status to lookup
    #
    # Example
    #
    #   Article.status_text(5)      # => "Published"
    #   Article.status_text(:draft) # => "Draft"
    #
    # Returns String
    def status_text(status)
       self.find_status_by_id(status).try(:text)
    end


    # Add a status to this class
    #
    # Arguments
    # * key        - (Symbol) The key for the new status
    # * attributes - (Hash) A Hash of attributes to give to the status
    #                (default: {})
    # * block      - An optional block which will yield to an
    #                instance of Status
    #
    # Example
    #
    #   # With Block:
    #   Article.status(:draft) do |s|
    #     s.id = 0
    #     s.text = "Draft"
    #     s.unpublished!
    #   end
    #
    #   # With Attributes:
    #   Article.status(:draft, id: 0, text: "Draft", type: :unpublished)
    #
    # Returns Status
    def status(key, attributes={})
      status = if block_given?
        s = Status.new(key)
        yield s
        s
      else
        Status.new(key, attributes)
      end

      self.statuses.push(status)
      status
    end
  end # ClassMethodsOnActivation


  module InstanceMethodsOnActivation
    # Get the current status type
    #
    # Example
    #
    #   article.status = self.class.find_status_by_key(:live).id
    #   article.status_type => :published
    #
    # Returns Symbol
    def status_type
      self.class.find_status_by_id(self.status).try(:type)
    end


    # Get what the status type was
    #
    # Example
    #
    #   article.status #=> 0 (:draft)
    #   article.status = self.class.find_status_by_key(:live).id
    #   article.status_type_was => :draft
    #
    # Returns Symbol
    def status_type_was
      self.class.find_status_by_id(self.status_was).try(:type)
    end


    # Check if the current status is the given key
    #
    # Example
    #
    #   article.status = self.class.find_status_by_key(:live).id
    #   article.status_is?(:live) #=> true
    #
    # Returns Boolean
    def status_is?(key)
      self.class.find_status_by_key(key).try(:id) == self.status
    end


    # Check if the status was the given key
    #
    # Example
    #
    #   article.status #=> 0 (:draft)
    #   article.status = self.class.find_status_by_key(:live).id
    #   article.status_was?(:draft) #=> true
    #
    # Returns Boolean
    def status_was?(key)
      self.class.find_status_by_key(key).try(:id) == self.status_was
    end


    # Check if the current status is the given type
    #
    # Example
    #
    #   @article.status = self.class.find_status_by_key(:live).id
    #   self.status_type_is?(:published) #=> true
    #
    # Returns Boolean
    def status_type_is?(type)
      self.status_type == type
    end


    # Check if the status was the given type
    #
    # Example
    #
    #   @article.status => 0 (:draft)
    #   @article.status = self.class.find_status_by_key(:live).id
    #   self.status_type_was?(:unpublished) #=> true
    #
    # Returns Boolean
    def status_type_was?(type)
      self.status_type_was == type
    end


    # Check if the current status is unpublished type
    #
    # Example
    #
    #   @article.status = self.class.find_status_by_key(:draft).id
    #   self.unpublished? #=> true
    #
    # Returns Boolean
    def unpublished?
      self.status_type_is?(:unpublished)
    end


    # Check if the current status is pending type
    #
    # Example
    #
    #   @article.status = self.class.find_status_by_key(:pending).id
    #   self.pending? #=> true
    #
    # Returns Boolean
    def pending?
      self.status_type_is?(:pending)
    end


    # Check if the current status is published type
    #
    # Example
    #
    #   @article.status = self.class.find_status_by_key(:live).id
    #   self.published? #=> true
    #
    # Returns Boolean
    def published?
      self.status_type_is?(:published)
    end


    # Check if we're going from unpublished to published
    #
    # Example
    #
    #   @article.status #=> 0 (:draft)
    #   @article.status = self.class.find_status_by_key(:live).id
    #   self.publishing? #=> true
    #
    # Returns Boolean
    def publishing?
      self.status_changed? &&
      self.published? &&
      !self.status_type_was?(:published)
    end


    # Check if we're going from published to unpublished
    #
    # Example
    #
    #   @article.status #=> 5 (:live)
    #   @article.status = self.class.find_status_by_key(:draft).id
    #   self.unpublishing? #=> true
    #
    # Returns Boolean
    def unpublishing?
      self.status_changed? &&
      !self.published? &&
      self.status_type_was?(:published)
    end


    # Get the text for this record's status
    #
    # Example
    #
    #   @article.status #=> 0 (:draft)
    #   @article.status_text #=> "Draft"
    #
    # Returns String or nil
    def status_text
      self.class.status_text(self.status)
    end
  end
end

ActiveRecord::Base.send :include, StatusBuilder

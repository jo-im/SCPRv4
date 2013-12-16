# Build yo statuses

module StatusBuilder
  extend ActiveSupport::Concern

  module ClassMethods
    # Activate the status methods for a class.
    def has_status
      extend ClassMethodsOnActivation
    end
  end


  module ClassMethodsOnActivation
    # A collection of this class's statuses
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
    #   Article.status_ids(:live, :draft) => [5, 0]
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
    #   Article.status_id(:live) => 5
    #
    # Returns Integer or nil
    def status_id(key)
      self.find_status_by_key(key).try(:id)
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
  end
end

ActiveRecord::Base.send :include, StatusBuilder

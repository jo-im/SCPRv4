# Methods to help with Status management
# Requires StatusBuilder
module Concern
  module Methods
    module StatusMethods
      extend ActiveSupport::Concern

      module ClassMethods
        def status_select_collection
          self.statuses.map { |s| [s.text, s.id] }
        end
      end


      # Check if the current status is the given key
      #
      # Example
      #
      #   @article.status = self.class.find_status_by_key(:live).id
      #   self.status_is?(:live) #=> true
      #
      # Returns Boolean
      def status_is?(key)
        self.class.find_status_by_key(key).map(&:id).include?(self.status)
      end


      # Check if the status was the given key
      #
      # Example
      #
      #   @article.status #=> 0 (:draft)
      #   @article.status = self.class.find_status_by_key(:live).id
      #   self.status_was?(:draft) #=> true
      #
      # Returns Boolean
      def status_was?(key)
        self.class.find_status_by_key(key).map(&:id).include?(self.status_was)
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
        self.class.find_status_by_type(type).map(&:id).include?(self.status)
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
        self.class.find_status_by_type(type).map(&:id).include?(self.status_was)
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
        self.class.find_status_by_id(self.status).try(:text)
      end
    end
  end
end

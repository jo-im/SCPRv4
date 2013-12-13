##
# CacheExpirationCallback
#
# Expires cache
# Requires the methods defined in StatusMethods
#
# We have to set the "promises" before save so that we still have
# access to the object's dirty attributes (status). Otherwise we
# don't know if the article was just published, unpublished, or what.
#
# But we don't want to expire the cache before the record is actually
# committed to the database, because there is a small chance that the
# cache could be rewritten with the old object, before it's committed.
#
module Concern
  module Callbacks
    module CacheExpirationCallback
      extend ActiveSupport::Concern

      included do
        include Concern::Methods::StatusMethods

        promise_to :expire_dependencies_on_self,
          :if => :should_expire_dependencies_on_self?

        promise_to :expire_dependencies_on_new_objects,
          :if => :should_expire_dependencies_on_new_objects?
      end


      private

      def should_expire_dependencies_on_self?
        # If we are going from "published" -> "published" (still),
        # or we are going from "published" -> "unpublished",
        # just expire this object
        (self.published? && !self.publishing?) ||
        self.destroyed? ||
        self.unpublishing?
      end

      def should_expire_dependencies_on_new_objects?
        # If we are going from "not published" -> "published".
        # Expire :new keys for the object's class and contentbase
        self.publishing?
      end

      def expire_dependencies_on_self
        Rails.cache.expire_obj(self)
      end

      def expire_dependencies_on_new_objects
        Rails.cache.expire_obj(self.class.new_obj_key)
        Rails.cache.expire_obj(ContentBase.new_obj_key)
      end
    end # CacheExpiration
  end # Callbacks
end # Concern

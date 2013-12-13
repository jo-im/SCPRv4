# Encapsulate the pattern in which you want to perform some
# action in a callback, but it can't happen until after the
# transaction has finished. This is useful for cache expiration
# or database (eg. Sphinx) indexing.
#
# We can't just use `after_commit` directly in the model,
# because Rails reloads the object BEFORE this callback is
# run. This makes checking things like dirty attributes
# impossible.
#
# Usage
#
# Using the `promise_to` macro, pass a method that should be run
# in an after_commit hook. Any options passed will be passed
# directly to the callbacks.
module Promise
  extend ActiveSupport::Concern

  module ClassMethods
    # Promise to perform an action in an after_commit hook.
    # The callback will promise to run on `after_save`
    # and on `after_destroy`.
    #
    # Arguments
    #
    # * method  - (Symbol) The method to run
    # * options - (Hash) A hash of options to pass to the callbacks.
    #             (default: {})
    #
    # Example
    #
    #   class Article < ActiveRecord::Base
    #     promise_to :clear_cache, :if => :should_clear_cache?
    #
    #     private
    #
    #     def should_clear_cache?
    #       self.published?
    #     end
    #
    #     def clear_cache
    #       Rails.cache.clear
    #     end
    #   end
    def promise_to(method, options={})
      promise = :"promise_to_#{method}"

      module_eval <<-EOE, __FILE__, __LINE__ + 1
        def #{promise}
          @_#{promise} = true
        end

        def promised_to_#{method}?
          !!@_#{promise}
        end

        def clear_#{promise}
          @_#{promise} = nil
        end
      EOE

      after_save promise, options
      after_destroy promise, options

      # These get run in the reverse order that they're defined.
      # I don't know why.
      after_commit :"clear_#{promise}"
      after_commit method, :if => :"promised_to_#{method}?"
    end
  end
end

ActiveRecord::Base.send :include, Promise

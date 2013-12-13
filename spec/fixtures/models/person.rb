module TestClass
  class Person < ActiveRecord::Base
    self.table_name = "test_class_people"

    include Concern::Validations::SlugValidation

    # Just allows any valid URL
    validates :twitter_url, url: { allow_blank: true, message: "bad url" }

    attr_accessor :kittens
    alias :kittens? :kittens

    promise_to :touch_associated, :if => :should_touch_associated?
    promise_to :update_index, :if => :should_update_index?


    private

    # Test on save
    def should_touch_associated?
      self.persisted?
    end

    # Test on destroy
    def should_update_index?
      self.destroyed?
    end

    def touch_associated
      # Touch associated object (stub me)
      true
    end

    def update_index
      # Update the index (you should stub this method)
      true
    end
  end
end

module TestClass
  class Person < ActiveRecord::Base
    self.table_name = "test_class_people"

    include Concern::Validations::SlugValidation

    # Just allows any valid URL
    validates :twitter_url, url: { allow_blank: true, message: "bad url" }

    promise_to :update_index, :if => :should_update_index?


    private

    def should_update_index?
      self.changed? || self.destroyed?
    end

    def update_index
      # Update the index (you should stub this method)
      true
    end
  end
end

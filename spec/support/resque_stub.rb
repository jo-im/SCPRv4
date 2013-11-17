if Rails.env.test?
  module Resque
    def self.enqueue(klass, *args)
      true
    end
  end
end

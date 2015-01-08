if Rails.env.test?
  module Resque
    def self.enqueue(klass, *args)
      # Run resque jobs inline
      if klass.is_a?(String)
        klass = klass.constantize
      end

      if klass::SHOULD_RUN_IN_TEST
        klass.perform(*args)
      else
        true
      end
    end
  end
end

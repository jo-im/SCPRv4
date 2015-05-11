if Rails.env.test?
  module Resque
    mattr_accessor :run_in_tests do
      []
    end

    def self.enqueue(klass, *args)
      # Run resque jobs inline
      if klass.is_a?(String)
        klass = klass.constantize
      end

      if Resque.run_in_tests.include?(klass)
        klass.perform(*args)
      else
        true
      end
    end
  end
end

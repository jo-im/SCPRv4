##
# Namespace for storing Resque jobs.
#
module Job
  # Queue definitions
  # We organize queues by priority to keep everything simple and let us
  # manage the queue more easily from here. Also, using only
  # a handful of queues encourages us to use less workers, therefore
  # keeping Resque's (already large) memory footprint manageable.
  #
  # Generally, a lower priority queue will have more jobs on it,
  # since the speed at which a lower-priority job gets run is less
  # important than that of a higher-priority job.
  #
  # * low_priority should be for actions that don't have to happen
  #   immediately and which aren't user-triggered. Generally
  #   these will be tasks triggered by a cron job.
  #   There can be any number of low_priority workers running.
  #
  # * mid_priority should be for actions which are user-triggered but
  #   don't need to happen immediately.
  #   There can be any number of mid_priority workers running.
  #
  # * high_priority should be reserved for actions which need to happen
  #   immediately. This might be a job which is the user is waiting for
  #   completion before moving on to another task.
  #   There can be any number of high_priority workers running.

  QUEUES = {
    :low_priority     => "low_priority",
    :mid_priority     => "mid_priority",
    :high_priority    => "high_priority",
  }

  class Base
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    SHOULD_RUN_IN_TEST = false

    class << self
      # Get the queue based on the defined priority.
      # Uses :low priority by default.
      # If your job needs a queue that isn't priority-based,
      # just override this method.
      # "priority" is a hard word to type.
      def queue
        @priority ||= :low
        QUEUES[:"#{@priority}_priority"]
      end

      def log(message, verbose=false)
        message = "*** #{message}"

        # Rails log and custom log always gets it
        Rails.logger.info message
        logger.info("***[#{Time.zone.now}] #{self.name}: #{message}")

        # STDOUT only gets it if requested
        if !!ENV['VERBOSE'] || verbose
          $stdout.puts message
        end
      end


      def enqueue(*args)
        Resque.enqueue(self, *args)
      end

      #---------------

      def cache(*args)
        cacher.cache(*args)
      end


      private

      def logger
        @logger ||= Logger.new(Rails.root.join("log", "jobs.log"))
      end

      def cacher
        @cacher ||= CacheController.new
      end

      def timeout_retry(max_tries, &block)
        tries = 0
        begin
          yield
        rescue Faraday::Error::TimeoutError => e
          if tries < max_tries
            tries += 1
            logger.info "Trying again... (Try #{tries} of #{max_tries}"
            retry
          else
            raise e
          end
        end
      end
    end


    #---------------

    def log(*args)
      self.class.log(*args)
    end
  end
end

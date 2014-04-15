module Job
  class BuildRecurringSchedule < Base
    @priority = :low

    class << self
      def perform
        next_month = 1.month.from_now
        start_date = next_month.beginning_of_month
        end_date   = next_month.end_of_month

        RecurringScheduleRule.create_occurrences(
          :start_date   => start_date,
          :end_date     => end_date
        )
      end
    end
  end
end

module Job
  class BuildRecurringSchedule < Base
    @priority = :low

    class << self
      def perform
        start_date = Time.zone.now
        end_date   = Time.zone.now + 2.weeks

        RecurringScheduleRule.recreate_occurrences(
          :start_date   => start_date,
          :end_date     => end_date
        )
      end
    end
  end
end

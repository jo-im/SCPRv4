module Job
  class ReportScheduleProblems < Base
    @priority = :low

    class << self
      def perform
        gaps     = ScheduleOccurrence.gaps
        overlaps = ScheduleOccurrence.overlaps

        puts "GAPS:"
        p gaps
        puts "OVERLAPS:"
        p overlaps
        nil
      end
    end
  end
end

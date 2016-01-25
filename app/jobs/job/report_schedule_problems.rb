module Job
  class ReportScheduleProblems < Base
    @priority = :low

    class << self
      def perform
        problems = ScheduleOccurrence.problems
        gaps     = problems[:gaps]     || []
        overlaps = problems[:overlaps] || []

        logger.info("Gaps have been spotted in the program schedule.") if gaps.any? 
        logger.info("Overlapping has been spotted in the program schedule.") if overlaps.any? 
        if gaps.any? || overlaps.any?
          ReportScheduleProblemsMailer.send_notification(gaps, overlaps).deliver_now
        end
        nil
      end
    end
  end
end

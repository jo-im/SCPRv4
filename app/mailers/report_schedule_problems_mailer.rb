class ReportScheduleProblemsMailer < ActionMailer::Base
  def send_notification gaps, overlaps
    @gaps     = gaps
    @overlaps = overlaps
    mail(to: "scprscheduleproblems@safetymail.info",
         from: "scprweb@scpr.org",
         subject: "There is a problem with the KPCC program schedule")
  end
end

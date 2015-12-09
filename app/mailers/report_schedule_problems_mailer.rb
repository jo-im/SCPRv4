class ReportScheduleProblemsMailer < ApplicationMailer
  def send_notification gaps, overlaps
    @gaps     = gaps
    @overlaps = overlaps
    mail(to: "scprscheduleproblems@safetymail.info",
         subject: "There is a problem with the KPCC program schedule")
  end
end

class ReportScheduleProblemsMailer < ApplicationMailer
  def send_notification gaps, overlaps
    @gaps     = gaps
    @overlaps = overlaps
    mail(to: Rails.application.secrets.emails.digital_broadcast_ops,
         subject: "There is a problem with the KPCC program schedule")
  end
end
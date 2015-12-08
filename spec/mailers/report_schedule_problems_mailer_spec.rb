require "spec_helper"

describe ReportScheduleProblemsMailer do
  describe "#send_notification" do

    let(:gaps) {       
      [[create(:schedule_occurrence), create(:schedule_occurrence)]]
    }

    let(:overlaps) {       
      [[create(:schedule_occurrence), create(:schedule_occurrence)]]
    }    

    it "sends the email" do
      ActionMailer::Base.deliveries.size.should eq 0
      ReportScheduleProblemsMailer.send_notification(gaps, overlaps).deliver_now
      ActionMailer::Base.deliveries.size.should eq 1
    end

  end
end

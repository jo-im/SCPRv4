require "spec_helper"

describe BreakingNewsAlert do
  describe '::expire_alert_fragment' do
    it 'runs after save and expires the fragment' do
      set_key = "obj:#{BreakingNewsAlert::FRAGMENT_EXPIRE_KEY}"
      fragment_key = "breaking_news"
      $redis.set(fragment_key, "oimate")
      $redis.sadd(set_key, fragment_key)

      $redis.get(fragment_key).should eq "oimate"
      alert = create :breaking_news_alert
      alert.save!
      $redis.get(fragment_key).should eq nil
    end
  end

  describe '#publish' do
    it "published the alert" do
      alert = create :breaking_news_alert, :unpublished
      alert.published?.should eq false

      alert.publish
      alert.published?.should eq true
    end
  end


  describe '#publish_mobile_notification' do
    before :each do
      stub_request(:post, %r|api\.parse\.com|)
      .to_return(body: { result: true }.to_json)
    end

    it 'publishes the notification if it should' do
      alert = create :breaking_news_alert, :mobile, :published
      alert.mobile_notification_sent?.should eq false

      alert.publish_mobile_notification
      alert.reload.mobile_notification_sent?.should eq true
    end

    it 'returns false and does not publish if it is not published' do
      alert = create :breaking_news_alert, :mobile, :draft
      alert.publish_mobile_notification.should eq false
      alert.reload.mobile_notification_sent?.should eq false
    end

    it 'returns false and does not publish if it is not mobilized' do
      alert = create :breaking_news_alert, :published
      alert.publish_mobile_notification.should eq false
      alert.reload.mobile_notification_sent?.should eq false
    end
  end


  describe '#async_send_mobile_notification' do
    it 'enqueues the job' do
      alert = create :breaking_news_alert

      Resque.should_receive(:enqueue).with(
        Job::SendMobileNotification, "BreakingNewsAlert", alert.id)

      alert.async_send_mobile_notification
    end
  end

  #-----------------------

  describe "sending the e-mail" do
    describe "job queue" do
      it "queues the job when email should be published" do
        alert = build :breaking_news_alert, :published, send_email: true

        alert.should_receive(:async_send_email)
        alert.save!
      end

      it "doesn't queue the job if the email shouldn't be sent" do
        alert = build :breaking_news_alert, :published, send_email: false

        alert.should_not_receive(:async_send_email)
        alert.save!
      end
    end

    describe '#publish_email' do
      before do
        stub_request(:post, %r|assets/email|).to_return({
          :content_type   => "application/json",
          :body           => load_fixture("api/eloqua/email.json")
        })

        stub_request(:post, %r|assets/campaign/active|).to_return({
          :content_type   => "application/json",
          :body           => load_fixture("api/eloqua/campaign_activated.json")
        })

        stub_request(:post, %r|assets/campaign\z|).to_return({
          :content_type   => "application/json",
          :body           => load_fixture("api/eloqua/email.json")
        })

        # Just incase, we don't want this method queueing anything
        # since we're testing the publish method directly.
        BreakingNewsAlert.any_instance.stub(:async_send_email)
      end

      it "sends an e-mail if the alert is published" do
        alert = create :breaking_news_alert, :published, send_email: true
        alert.publish_email
        alert.email_sent?.should eq true
      end

      it "doesn't send an e-mail if the alert is not published" do
        alert = create :breaking_news_alert, :draft, send_email: true
        alert.publish_email
        alert.email_sent?.should eq false
      end

      it "doesn't send an e-mail if send_email is false" do
        alert = create :breaking_news_alert, :published, send_email: false
        alert.publish_email
        alert.email_sent?.should eq false
      end

      it "doesn't send an e-mail if one has already been sent" do
        alert = create :breaking_news_alert, :published,
          :email_sent => true,
          :send_email => true

        alert.should_not_receive(:update_column).with(:email_sent, true)
        alert.publish_email
      end
    end
  end

  describe '#break_type' do
    it 'gets the human-friendly alert type' do
      alert = build :breaking_news_alert
      alert.break_type.should eq "Breaking News"
    end
  end

  describe '#as_eloqua_email' do
    let(:alert) {
      build :breaking_news_alert,
        headline: "Hundreds Die in Fire; Grep Proops Unharmed"
    }

    describe 'html_body' do
      it 'is a string containing some html' do
        alert.as_eloqua_email[:html_body].should match /<html/
      end
    end

    describe 'plain_text_body' do
      it 'is a string containing some text' do
        alert.as_eloqua_email[:plain_text_body].should match alert.headline
      end
    end

    describe 'name' do
      it 'is a string with part of the headline in it' do
        alert.as_eloqua_email[:name]
          .should eq "[scpr-alert] #{alert.headline[0..30]}"
      end
    end

    describe 'description' do
      it 'has the subject and some descriptive stuff and junk' do
        alert.as_eloqua_email[:description].should match alert.headline
      end
    end

    describe 'subject' do
      it 'has the subject and some descriptive stuff and junk' do
        subject = alert.as_eloqua_email[:subject]
        subject.should match alert.break_type
        subject.should match alert.headline
      end
    end
  end

  #-----------------------

  describe "::published" do
    it "only returns published alerts" do
      pub     = create :breaking_news_alert, :published
      unpub   = create :breaking_news_alert, :draft
      BreakingNewsAlert.published.should eq [pub]
    end

    it "orders by published_at desc" do
      BreakingNewsAlert.published.to_sql.should match /order by published_at desc/i
    end
  end

  describe "::visible" do
    it "only returns visible alerts" do
      visible     = create :breaking_news_alert, visible: true
      invisible   = create :breaking_news_alert, visible: false
      BreakingNewsAlert.visible.should eq [visible]
    end
  end

  #-----------------------

  describe "::latest_visible_alert" do
    it "returns the most recent published and visible alert" do
      alert = create :breaking_news_alert, :published,
        :visible        => true,
        :published_at   => 1.day.ago

      alert2 = create :breaking_news_alert, :published,
        :visible        => true,
        :published_at   => 1.hour.ago

      alert3 = create :breaking_news_alert, :published,
        :visible        => false,
        :published_at   => Time.now

      BreakingNewsAlert.latest_visible_alert.should eq alert2
    end

    it "returns nil if there are no alerts" do
      BreakingNewsAlert.count.should eq 0
      BreakingNewsAlert.latest_visible_alert.should be_nil
    end
  end
end

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
        Job::SendBreakingNewsMobileNotification, alert.id)

      alert.async_send_mobile_notification
    end
  end

  #-----------------------

  describe "sending the e-mail callback" do
    it "queues the job when email should be published" do
      alert = build :breaking_news_alert, :published, send_email: true
      alert.should_send_email?.should eq true

      alert.should_receive(:async_send_email)
      alert.save!
    end

    it "doesn't queue the job if the email shouldn't be sent" do
      alert = build :breaking_news_alert, :published, send_email: false
      alert.should_send_email?.should eq false

      alert.should_not_receive(:async_send_email)
      alert.save!
    end
  end

  describe '#should_send_email?' do
    it "is true if published, we want to send, and the e-mail hasn't been sent" do
      alert = build :breaking_news_alert, :published, send_email: true, email_sent: false
      alert.should_send_email?.should eq true
    end

    it "is false if the email has already been sent" do
      alert = build :breaking_news_alert, :published, send_email: true, email_sent: true
      alert.should_send_email?.should eq false
    end

    it "is false if an e-mail isn't requested" do
      alert = build :breaking_news_alert, :published, send_email: false
      alert.should_send_email?.should eq false
    end

    it "is false if unpublished" do
      alert = build :breaking_news_alert, :unpublished, send_email: true
      alert.should_send_email?.should eq false
    end
  end


  describe '#break_type' do
    it 'gets the human-friendly alert type' do
      alert = build :breaking_news_alert
      alert.break_type.should eq "Breaking News"
    end
  end

  describe '#email_html_body' do
    it 'is a string containing some html' do
      alert = build :breaking_news_alert
      alert.email_html_body.should match /<html/
    end
  end

  describe '#email_plain_text_body' do
    it 'is a string containing some text' do
      alert = build :breaking_news_alert
      alert.email_plain_text_body.should match alert.headline
    end
  end

  describe '#email_name' do
    it 'is a string with part of the headline in it' do
      alert = build :breaking_news_alert, headline: "some important news"
      alert.email_name.should match /some important news/
    end
  end

  describe '#email_description' do
    it 'has the subject and some descriptive stuff and junk' do
      alert = build :breaking_news_alert, headline: "Hundreds Die in Fire; Grep Proops Unharmed"
      alert.email_description.should match alert.headline
    end
  end

  describe '#email_subject' do
    it 'has the subject and some descriptive stuff and junk' do
      alert = build :breaking_news_alert, headline: "Hundreds Die in Fire; Grep Proops Unharmed"
      alert.email_subject.should match alert.break_type
      alert.email_subject.should match alert.headline
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

  describe "::latest_alert" do
    it "returns the first alert if it is published and visible" do
      alert = create :breaking_news_alert, :published, visible: true
      BreakingNewsAlert.latest_alert.should eq alert
    end

    it "returns nil if there are no alerts" do
      BreakingNewsAlert.count.should eq 0
      BreakingNewsAlert.latest_alert.should be_nil
    end

    it "returns nil if the first alert is not visible" do
      # Older alert, visible
      older = create :breaking_news_alert, created_at: Time.now.yesterday, visible: true
      # Latest alert, invisible
      latest = create :breaking_news_alert, created_at: Time.now, visible: false

      # Only looking at the latest alert
      BreakingNewsAlert.latest_alert.should be_nil
    end
  end
end

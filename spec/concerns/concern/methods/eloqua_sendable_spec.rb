require 'spec_helper'

describe Concern::Methods::EloquaSendable do
  describe '::eloqua_config' do
    it 'gets eloqua config for the class' do
      TestClass::Alert.eloqua_config.should be_a Hash
      TestClass::Alert.eloqua_config.should have_key "email_group_id"
    end

    it "raises an error if the configuration is missing" do
      Rails.configuration.stub(:api) do
        { 'eloqua' => { 'attributes' => {} } }
      end

      expect { TestClass::Alert.eloqua_config }.to raise_error
    end
  end


  describe "#publish_email" do
    before :each do
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
    end

    it 'sends the e-mail and sets email_sent? to true if it should publish' do
      alert = create :test_class_alert, email_sent: false

      alert.publish_email
      alert.reload.email_sent?.should eq true
    end

    it 'does not send the email if it should not publish' do
      alert = create :test_class_alert, send_email: false

      alert.publish_email
      alert.reload.email_sent?.should eq false
    end
  end


  describe '#async_send_email' do
    it 'enqueues the job' do
      alert = build :test_class_alert
      alert.id = 999

      Resque.should_receive(:enqueue).with(
        Job::SendEmailNotification, "TestClass::Alert", 999)

      alert.async_send_email
    end
  end
end

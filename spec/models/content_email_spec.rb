require "spec_helper"

describe ContentEmail do
  describe "validations" do
    it { should validate_presence_of :from_email }
    it { should validate_presence_of :to_email }
    it { should validate_presence_of :content_key }
    it { should allow_value("other-guy@gmail.com").for(:from_email) }
    it { should allow_value("other-guy@gmail.com").for(:to_email) }
    it { should_not allow_value("noway jose @ whatever").for(:to_email).with_message(/invalid/i) }
    it { should_not allow_value("nowayjose@whatever").for(:from_email).with_message(/invalid/i) }
  end

  #-----------

  describe "initialize" do
    it "sets all attributes passed in" do
      content_email = ContentEmail.new({
        :from_name    => "Bricker",
        :from_email   => "bricker@bricker.com",
        :to_email     => "bricker@scpr.org",
        :content_key  => "blog_entry-999"
      })

      content_email.from_name.should  eq "Bricker"
      content_email.from_email.should eq "bricker@bricker.com"
      content_email.to_email.should   eq "bricker@scpr.org"
      content_email.content_key.should eq nil
    end

    it "can accept string values too" do
      content_email = ContentEmail.new({
        "from_name"    => "Bricker"
      })

      content_email.from_name.should eq "Bricker"
    end
  end

  #-----------

  describe "save" do
    context "valid" do
      let(:content) { create :news_story }

      let(:content_email) do
        build :content_email,
          :from_email   => "bricker@bricker.com",
          :to_email     => "bricker@scpr.org",
          :content_key  => content.obj_key
      end

      it "enqueues the delivery" do
        Job::DelayedMailer.should_receive(:enqueue).with(
          "ContentMailer", :email_content,
          [content_email.to_json, content.obj_key]
        )

        content_email.save
      end

      it "returns self" do
        content_email.save.should eq content_email
      end
    end

    context "invalid" do
      let(:content_email) { build :content_email, to_email: "invalid" }

      it "is invalid when content_key isn't allowed" do
        content_email.content_key = "admin_user-123"
        content_email.valid?.should be_false
        content_email.errors.keys.should include :base
      end

      it "returns false" do
        content_email.save.should eq false
      end

      it "does not enqueue the delivery" do
        Job::DelayedMailer.should_not_receive(:enqueue)
      end
    end
  end

  #-----------

  describe "from" do
    it "returns the from_name if it's available" do
      content_email = build :content_email, from_name: "Bryan"
      content_email.from.should eq content_email.from_name
    end

    it "returns the from_email if from_name isn't available" do
      content_email = build :content_email, from_name: nil
      content_email.from.should eq content_email.from_email
    end
  end
end

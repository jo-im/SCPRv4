require "spec_helper"

describe ContentEmailController do
  render_views

  describe "GET /new" do
    let(:content) { create :news_story }

    it "renders `minimal` layout" do
      get :new, obj_key: content.obj_key
      response.should render_with_layout 'minimal'
    end

    it "sets @message to a new ContentEmail object" do
      get :new, obj_key: content.obj_key
      assigns(:message).should be_a ContentEmail
    end

    it "assigns @content to an object based on the :obj_key" do
      get :new, obj_key: content.obj_key
      assigns(:content).should eq content
    end

    it "raises 404 if content isnt found" do
      -> { get :new }.should raise_error ActiveRecord::RecordNotFound

      -> {
        get :new, obj_key: "wrong"
      }.should raise_error ActiveRecord::RecordNotFound
    end

    it "raises 404 if the content isn't allowed" do
      admin_user = create :admin_user

      -> {
        get :new, obj_key: admin_user.obj_key
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end

  #-------------------

  describe "POST /create" do
    let(:content)  { create :news_story }

    context "valid message" do
      before :each do
        post :create,
          :obj_key => content.obj_key,
          :content_email => {
            :from_name    => "Bryan",
            :from_email   => "bricker@scpr.org",
            :to_email     => "bricker@kpcc.org"
          }
      end

      it "renders the success template" do
        response.should render_template "success"
      end

      it "initializes a new ContentEmail with the form params" do
        message = assigns(:message)
        message.should be_a ContentEmail
        message.from_name.should eq   "Bryan"
        message.from_email.should eq  "bricker@scpr.org"
        message.to_email.should eq    "bricker@kpcc.org"
      end

      it "sets @message.content to @content" do
        assigns(:message).content_key.should eq content.obj_key
      end
    end

    context "invalid message" do
      it "renders the new template" do
        post :create,
          :obj_key          => content.obj_key,
          :content_email    => { to_email: "invalid" }

        response.should render_template 'new'
      end

      it "sets @content" do
        post :create,
          :obj_key          => content.obj_key,
          :content_email    => { to_email: "invalid" }

        assigns(:content).should_not be_nil
      end

      it "raises 404 if the content isn't allowed" do
        admin_user = create :admin_user

        -> {
          post :create,
            :content_email => { to_email: "whatever" },
            :obj_key       => admin_user.obj_key
        }.should raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end

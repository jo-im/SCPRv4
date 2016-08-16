require "spec_helper"

describe Outpost::RemoteArticlesController do
  render_views
  let(:resource) { :npr_article }

  before :each do
    @resource_properties = Array(resource)
    @resource = @resource_properties.first

    @object         = create *@resource_properties
    @current_user   = create :admin_user, is_superuser: false
    controller.stub(:current_user) { @current_user }
  end


  context "without proper permission" do
    describe 'GET /index' do
      it "redirects to outpost root" do
        get :index
        response.should redirect_to "/outpost/"
      end
    end

    describe 'POST /sync' do
      it "redirects to outpost root" do
        post :sync
        response.should redirect_to "/outpost/"
      end
    end

    describe 'POST /import' do
      it "redirects to outpost root" do
        post :import, id: @object.id
        response.should redirect_to "/outpost/"
      end
    end

    describe 'PUT /skip' do
      it "redirects to outpost root" do
        put :skip, id: @object.id
        response.should redirect_to "/outpost/"
      end
    end
  end


  context "with proper permissions" do
    before :each do
      @current_user.permissions <<
        Permission.find_by_resource(@object.class.name)
    end

    describe "GET /index" do
      it "responds with success" do
        get :index
        assigns(:records).should eq [@object]
        response.should be_success
      end

      it "only gets new records" do
        oldrecord = create :npr_article, is_new: false, article_id: (RemoteArticle.last.article_id.to_i + 1)
        get :index
        assigns(:records).should_not include oldrecord
      end
    end

    describe 'POST /sync' do
      it "enqueues the job and renders" do
        Resque.should_receive(:enqueue).with(Job::SyncRemoteArticles)

        post :sync
        response.should be_ok
        response.should render_template 'sync'
      end
    end

    describe 'POST /import' do
      it "enqueues the job and renders" do
        post :import, id: @object.id
        response.should be_ok
        response.should render_template 'import'
      end
    end

    describe 'PUT /skip' do
      it "sets is_new to false on the object" do
        expect {
          put :skip, id: @object.id
        }.to change { @object.reload.is_new }.to(false)

        response.should redirect_to outpost_remote_articles_path
      end
    end
  end
end

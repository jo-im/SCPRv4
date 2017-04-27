require "spec_helper"

# We have to copy this from shared resource controller specs because our
# assertions are a little bit different.
describe Outpost::AdminUsersController do
  let(:resource) { :admin_user }

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

    describe 'GET /activity' do
      it 'redirect to outpost root' do
        get :activity, id: @object.id
        response.should redirect_to "/outpost/"
      end
    end

    describe 'GET /show' do
      it "redirects to outpost root" do
        get :show, id: @object.id
        response.should redirect_to "/outpost/"
      end
    end

    describe 'GET /edit' do
      it "redirects to outpost root" do
        get :edit, id: @object.id
        response.should redirect_to "/outpost/"
      end
    end

    describe 'POST /create' do
      it "redirects to outpost root" do
        post :create, @resource => { who: "cares" }
        response.should redirect_to "/outpost/"
      end
    end

    describe 'PUT /update' do
      it "redirects to outpost root" do
        put :update, id: @object.id, @resource => { who: "cares" }
        response.should redirect_to "/outpost/"
      end
    end

    describe 'DELETE /destroy' do
      it "redirects to outpost root" do
        delete :destroy, id: @object.id
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
        assigns(:records).should eq [@object, @current_user]
        response.should be_success
      end
    end

    describe "GET /new" do
      it "responds with success" do
        get :new
        response.should be_success
      end
    end

    describe "POST /create" do
      it "creates the resource" do
        klass = @resource.to_s.classify.constantize

        expect {
          post :create, @resource => build_attributes(*@resource_properties)
            .except("password_digest")
            .merge(
              "password" => "secret",
              "password_confirmation" => "secret"
            )
        }.to change { klass.count }.by(1)

        # Redirect to index path because there is no commit_action parameter,
        # so it uses index path which is fallback.
        response.should redirect_to @object.class.admin_index_path
      end
    end

    describe "DELETE /destroy" do
      it "destroys the resource" do
        delete :destroy, id: @object.id
        assigns(:record).should eq @object
        response.should be_redirect
      end
    end
  end


  context "as the same user" do
    describe 'GET /activity' do
      it "gets the activity for this user" do
        story = create :news_story, logged_user_id: @current_user.id
        get :activity, id: @current_user.id
        assigns(:versions).should eq story.versions.to_a
      end
    end

    describe "GET /show" do
      it "redirects to edit" do
        get :show, id: @current_user.id
        assigns(:record).should eq @current_user
        response.should redirect_to @current_user.admin_edit_path
      end
    end

    describe "GET /edit" do
      it "responds with success" do
        get :edit, id: @current_user.id
        assigns(:record).should eq @current_user
        response.should be_success
      end
    end

    describe "PUT /update" do
      it "updates the record" do
        @current_user.update_column(:updated_at, 1.day.ago)

        expect {
          put :update,
            :id         => @current_user.id,
            @resource   => { name: "Bricker" }
        }.to change { @current_user.reload.updated_at }

        assigns(:record).should eq @current_user
        response.should redirect_to @current_user.class.admin_index_path
      end
    end

    describe "DELETE /destroy user" do
      it "does not destroy" do
        delete :destroy, id: @current_user.id
        AdminUser.find(@current_user.id).should_not be_destroyed

        response.should be_redirect
      end
    end
  end
end

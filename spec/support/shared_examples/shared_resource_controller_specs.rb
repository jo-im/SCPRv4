# These just make sure there are no blatant view errors.
# Could definitely be faster and more useful.

shared_examples_for "resource controller" do
  render_views

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
        response.should redirect_to outpost_root_path
      end
    end

    describe 'GET /show' do
      it "redirects to outpost root" do
        get :show, id: @object.id
        response.should redirect_to outpost_root_path
      end
    end

    describe 'GET /edit' do
      it "redirects to outpost root" do
        get :edit, id: @object.id
        response.should redirect_to outpost_root_path
      end
    end

    describe 'POST /create' do
      it "redirects to outpost root" do
        post :create, @resource => { who: "cares" }
        response.should redirect_to outpost_root_path
      end
    end

    describe 'PUT /update' do
      it "redirects to outpost root" do
        put :update, id: @object.id, @resource => { who: "cares" }
        response.should redirect_to outpost_root_path
      end
    end

    describe 'DELETE /destroy' do
      it "redirects to outpost root" do
        delete :destroy, id: @object.id
        response.should redirect_to outpost_root_path
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
    end

    describe "GET /show" do
      it "redirects to edit" do
        get :show, id: @object.id
        assigns(:record).should eq @object
        response.should redirect_to @object.admin_edit_path
      end
    end

    describe "GET /new" do
      it "responds with success" do
        get :new
        response.should be_success
      end
    end

    describe "GET /edit" do
      it "responds with success" do
        get :edit, id: @object.id
        assigns(:record).should eq @object
        response.should be_success
      end
    end

    describe "POST /create" do
      it "creates the resource" do
        klass = @resource.to_s.classify.constantize

        expect {
          post :create, @resource => build_attributes(*@resource_properties)
        }.to change { klass.count }.by(1)

        # Redirect to index path because there is no commit_action parameter,
        # so it uses index path which is fallback.
        response.should redirect_to @object.class.admin_index_path
      end
    end

    describe "PUT /update" do
      it "updates the record" do
        @object.update_column(:updated_at, 1.day.ago)

        expect {
          put :update,
            :id         => @object.id,
            @resource   =>  build_attributes(*@resource_properties)
        }.to change { @object.reload.updated_at }

        assigns(:record).should eq @object
        response.should redirect_to @object.class.admin_index_path
      end
    end

    describe "DELETE /destroy" do
      it "destroys the resource" do
        expect {
          delete :destroy, id: @object.id
        }.to change { @object.class.count }.by(-1)

        response.should be_redirect
      end
    end
  end
end

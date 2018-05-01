require "spec_helper"

describe Outpost::ShowEpisodesController do
  it_behaves_like "resource controller" do
    let(:resource) { :show_episode }
  end

  describe "preview" do
    render_views

    before :each do
      @current_user = create :admin_user
      controller.stub(:current_user) { @current_user }
    end

    let(:program) { create :kpcc_program, is_segmented: false }

    context "existing object" do
      context "with segmented program" do
        let(:program) { create :kpcc_program, is_segmented: true }

        it "builds the object and renders the segment list" do
          show_episode = create :show_episode, :published, headline: "This is a story", show: program
          put :preview, id: show_episode.id, obj_key: show_episode.obj_key, show_episode: show_episode.attributes.merge(headline: "Updated")
          assigns(:episode).should eq show_episode
          assigns(:episode).headline.should eq "Updated"
          response.should render_template "programs/standard_program_episode"
        end
      end

      it "builds the object from existing attributes and assigns new ones" do
        show_episode = create :show_episode, :published, headline: "This is a story", show: program
        put :preview, id: show_episode.id, obj_key: show_episode.obj_key, show_episode: show_episode.attributes.merge(headline: "Updated")
        assigns(:episode).should eq show_episode
        assigns(:episode).headline.should eq "Updated"
        response.should render_template "programs/kpcc/_episode"
      end

      it "renders validation errors if the object is not unconditionally valid" do
        show_episode = create :show_episode, headline: "Okay", show: program
        put :preview, id: show_episode.id, obj_key: show_episode.obj_key, show_episode: show_episode.attributes.merge(teaser: "")
        response.should render_template "outpost/shared/_preview_errors"
      end

      it "renders properly for unpublished content" do
        show_episode = create :show_episode, :draft, headline: "This is a story", show: program
        put :preview, id: show_episode.id, obj_key: show_episode.obj_key, show_episode: show_episode.attributes
        response.should render_template "programs/kpcc/_episode"
      end
    end

    context "new object" do
      context "with non-segmented program" do
        let(:program) { create :kpcc_program, is_segmented: true }

        it "builds the object and renders the segment list" do
          show_episode = create :show_episode, :published, headline: "This is a story", show: program
          put :preview, id: show_episode.id, obj_key: show_episode.obj_key, show_episode: show_episode.attributes.merge(headline: "Updated")
          assigns(:episode).should eq show_episode
          assigns(:episode).headline.should eq "Updated"
          response.should render_template "programs/standard_program_episode"
        end
      end

      it "builds a new object and assigns the attributes" do
        show_episode = build :show_episode, headline: "This is a story", show: program
        post :preview, obj_key: show_episode.obj_key, show_episode: show_episode.attributes
        assigns(:episode).headline.should eq "This is a story"
        response.should render_template "programs/kpcc/_episode"
      end

      it "renders validation errors if the object is not unconditionally valid" do
        show_episode = build :show_episode, headline: "okay", show: program
        post :preview, obj_key: show_episode.obj_key, show_episode: show_episode.attributes.merge(teaser: "")
        response.should render_template "outpost/shared/_preview_errors"
      end
    end
  end
end

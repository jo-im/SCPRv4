require "spec_helper"

describe Outpost::BlogEntriesController do
  it_behaves_like "resource controller" do
    let(:resource) { :blog_entry }
  end

  describe "preview" do
    render_views

    before :each do
      @current_user = create :admin_user
      @category = create :category
      controller.stub(:current_user) { @current_user }
    end

    context "existing object" do
      it "builds the object from existing attributes and assigns new ones" do
        entry = create :blog_entry, :published,
          :headline => "This is a blog entry",
          :category => @category

        put :preview,
          :id           => entry.id,
          :obj_key      => entry.obj_key,
          :blog_entry   => entry.attributes.merge(headline: "Updated")

        assigns(:entry).should eq entry
        assigns(:entry).headline.should eq "Updated"
        response.should render_template "blogs/_entry"
      end

      it "renders validation errors if object not unconditionally valid" do
        entry = create :blog_entry, headline: "Okay"
        put :preview,
          :id           => entry.id,
          :obj_key      => entry.obj_key,
          :blog_entry   => entry.attributes.merge(headline: "")

        response.should render_template "outpost/shared/_preview_errors"
      end

      it "renders properly for unpublished content" do
        entry = create :blog_entry, :draft,
          :headline => "This is a blog entry",
          :category => @category

        put :preview,
          :id           => entry.id,
          :obj_key      => entry.obj_key,
          :blog_entry   => entry.attributes

        response.should render_template "blogs/_entry"
      end

      describe "rolling back" do
        it "rolls back assets" do
          assets = build_list :asset, 2
          entry = create :blog_entry, :draft, assets: assets

          expect {
            put :preview,
              :id           => entry.id,
              :obj_key      => entry.obj_key,
              :blog_entry   => { asset_json: [].to_json }
          }.not_to change { entry.reload.assets }
        end

        it "rolls back bylines" do
          bylines = build_list :byline, 2
          entry = create :blog_entry, :draft, bylines: bylines

          expect {
            put :preview,
              :id => entry.id,
              :obj_key => entry.obj_key,
              :blog_entry => { bylines_attributes: {} }
          }.not_to change { entry.reload.bylines }
        end

        it "rolls back attributes" do
          entry = create :blog_entry, headline: "Original Headline"

          expect {
            put :preview,
              :id => entry.id,
              :obj_key => entry.obj_key,
              :blog_entry => { headline: "wat wat" }
          }.not_to change { entry.reload.headline }
        end
      end
    end

    context "new object" do
      it "builds a new object and assigns the attributes" do
        entry = build :blog_entry,
          :headline => "This is a blog entry",
          :category => @category

        post :preview, obj_key: entry.obj_key, blog_entry: entry.attributes
        assigns(:entry).headline.should eq "This is a blog entry"
        response.should render_template "blogs/_entry"
      end

      it "renders validation errors if object not unconditionally valid" do
        entry = build :blog_entry, headline: "okay"
        post :preview,
          :obj_key      => entry.obj_key,
          :blog_entry   => entry.attributes.merge(headline: "")

        response.should render_template "outpost/shared/_preview_errors"
      end


      describe "rolling back" do
        it "rolls back assets" do
          assets = build_list :asset, 2
          entry = build :blog_entry, :draft

          expect {
            post :preview,
              :obj_key      => entry.obj_key,
              :blog_entry   => entry.attributes.merge(
                { asset_json: assets.map(&:simple_json).to_json }
              )
          }.not_to change { ContentAsset.count }
        end

        it "rolls back bylines" do
          bylines = build_list :byline, 2
          entry = build :blog_entry, :draft

          expect {
            post :preview,
              :obj_key => entry.obj_key,
              :blog_entry => { bylines_attributes: bylines.map(&:attributes) }
          }.not_to change { ContentByline.count }
        end

        it "rolls back parent record" do
          entry = build :blog_entry

          expect {
            post :preview,
              :obj_key => entry.obj_key,
              :blog_entry => entry.attributes
          }.not_to change { BlogEntry.count }
        end
      end
    end
  end
end

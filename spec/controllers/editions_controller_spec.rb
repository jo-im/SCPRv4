require 'spec_helper'

describe EditionsController do
  describe "short_list" do
    render_views

    before :each do
      @edition = create :edition, :published, :with_abstract
      @edition_slots = create_list :edition_slot, 10, edition: @edition
    end

    it 'renders the view' do
      get :short_list, @edition.route_hash
    end

    it "renders the layout" do
      get :short_list, @edition.route_hash
      response.should render_template "new/ronin"
    end

    it "assigns @edition" do
      get :short_list, @edition.route_hash
      assigns(:edition).should eq @edition
    end

    it "assigns @other_editions" do
      other_editions = create_list :edition, 4, :published, :with_abstract

      get :short_list, @edition.route_hash
      assigns(:other_editions).should_not include(@edition)
    end

    it "raises ActionController::UrlGenerationError if edition slug does not exist" do
      edition = create :edition, :published
      -> {
        get :short_list, { id: edition.id, slug: '' }.merge!(date_path(edition.published_at))
      }.should raise_error ActionController::UrlGenerationError
    end
  end

  describe "latest" do
    render_views

    before :each do
      @edition = build :edition, :published, :with_abstract
      @edition_slots = create_list :edition_slot, 10, edition: @edition
    end

    it 'renders the view' do
      get :latest
    end

    it "renders the layout" do
      get :latest
      response.should render_template "new/ronin"
    end

    it "assigns @edition" do
      get :latest
      assigns(:edition).should eq @edition
    end

    it "assigns @other_editions" do
      other_editions = create_list :edition, 4, :with_abstract, published_at: @edition.published_at - 1.hour
      get :latest
      assigns(:other_editions).should_not include(@edition)
    end
  end

end

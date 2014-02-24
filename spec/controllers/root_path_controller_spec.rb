require "spec_helper"

describe RootPathController do
  describe "category" do
    render_views

    it "assigns @category" do
      category = create :category_news

      get :handle_path, path: category.slug
      assigns(:category).should eq category
    end

    describe "with XML" do
      it "renders xml template when requested" do
        category = create :category_news

        get :handle_path, path: category.slug, format: :xml

        response.should render_template 'category/feed'
        response.header['Content-Type'].should match /xml/
        response.body.should match RSS_SPEC['xmlns:atom']
      end
    end

    describe "with template" do
      context 'category is active' do
        before :each do
          @active_category = create :category_news, is_active: true
        end
        it "renders the new template" do
          get :handle_path, path: @active_category.slug, format: :html
          response.should render_template 'category/show'
        end
      end

      context 'category is inactive' do
        before :each do
         @inactive_category = create :category_news, is_active: false
        end
        it "renders the old template" do
          get :handle_path, path: @inactive_category.slug, format: :html
          response.should render_template 'category/simple'
        end
      end
    end
  end


  describe "vertical" do
    render_views

    describe "rendering articles with issues" do
      sphinx_spec

      it "renders articles and issues" do
        category = create :category, is_active: true
        issues = create_list :issue, 3, :is_active

        category.issues = issues
        articles = create_list :news_story, 6, :published, category: category
        articles.each { |a| a.issues = issues }

        index_sphinx

        ts_retry(2) do
          get :handle_path, path: category.slug, format: :html
          response.should be_success
        end
      end
    end

    describe "with XML" do
      it "renders xml template when requested" do
        category = create :category_news, is_active: true

        get :handle_path, path: category.slug, format: :xml

        response.should render_template 'category/feed'
        response.header['Content-Type'].should match /xml/
        response.body.should match RSS_SPEC['xmlns:atom']
      end
    end
  end

  #------------------

  describe "flatpage" do
    context "rendering" do
      render_views

      it "assigns @flatpage" do
        flatpage = create :flatpage
        get :handle_path, path: flatpage.path
        assigns(:flatpage).should eq flatpage
      end

      it "redirects if redirect_url is present" do
        flatpage = create :flatpage, redirect_to: "http://google.com"
        get :handle_path, path: flatpage.path
        response.should be_redirect
      end
    end

    #------------------

    context "not rendering" do
      it "does not render a template if template is none" do
        flatpage = create :flatpage, template: "none"
        get :handle_path, path: flatpage.path
        response.should render_template(layout: false)
      end


      it "renders application layout by default" do
        flatpage = create :flatpage
        get :handle_path, path: flatpage.path
        response.should render_template(layout: "layouts/application")
      end

      it "render no_sidebar if template is full" do
        flatpage = create :flatpage, template: "full"
        get :handle_path, path: flatpage.path
        response.should render_template(layout: "layouts/app_nosidebar")
      end
    end
  end

  #------------------

  describe "404" do
    it 'raises a ActionController::RoutingError if nothing is found' do
      -> {
        get :handle_path, path: "nonsense/whatever"
      }.should raise_error ActionController::RoutingError
    end
  end
end

require "spec_helper"

describe Api::Public::V2::ArticlesController do
  request_params = {
    :format => :json
  }

  render_views

  describe "GET show" do
    it "finds the object if it exists" do
      entry = create :blog_entry
      get :show, { obj_key: entry.obj_key }.merge(request_params)
      assigns(:article).should eq entry.to_article
      response.should render_template "show"
    end

    it "returns a 404 status if it does not exist" do
      get :show, { obj_key: "nope" }.merge(request_params)
      response.response_code.should eq 404
      response.body.should eq Hash[error: "Not Found"].to_json
    end
  end

  describe "GET by_url" do
    it "finds the object if the URI matches" do
      entry = create :blog_entry
      get :by_url, { url: entry.public_url }.merge(request_params)
      assigns(:article).should eq entry.to_article
      response.should render_template "show"
    end

    it "validates the URI, returning a bad request if not valid" do
      get :by_url, { url: '###' }.merge(request_params)
      response.response_code.should eq 400
    end

    it "returns a 404 if no object is found" do
      get :by_url, { url: "nope.com" }.merge(request_params)
      response.response_code.should eq 404
      response.body.should eq Hash[error: "Not Found"].to_json
    end
  end

  describe "GET most_viewed" do
    it "returns the cached articles" do
      articles = create_list(:blog_entry, 2).map(&:to_article)
      Rails.cache.write("popular/viewed", articles)

      get :most_viewed, request_params
      assigns(:articles).should eq articles
      response.body.should render_template "index"
    end

    it "returns an error if the cache is nil" do
      get :most_viewed, request_params
      assigns(:articles).should eq nil
      response.response_code.should eq 503
    end
  end

  describe "GET most_commented" do
    it "returns the cached articles" do
      articles = create_list(:blog_entry, 2).map(&:to_article)
      Rails.cache.write("popular/commented", articles)
      
      get :most_commented, request_params
      assigns(:articles).should eq articles
      response.body.should render_template "index"
    end

    it "returns an error if the cache is nil" do
      get :most_commented, request_params
      assigns(:articles).should eq nil
      response.response_code.should eq 503
    end
  end

  describe "GET index" do
    context 'with category parameter' do
      before :all do
        setup_sphinx
      end

      after :all do
        teardown_sphinx
      end

      it 'only selects stories with the requested categories' do
        category1  = create :category_not_news, slug: "film"
        story1     = create :news_story,
          category: category1, published_at: 1.hour.ago

        category2  = create :category_news, slug: "health"
        story2     = create :news_story,
          category: category2, published_at: 2.hours.ago

        # Control - add these in to make sure we're *only* returning
        # stories with the requested categories
        category3  = create :category_news, slug: "wat"
        story3     = create :news_story,
          category: category3, published_at: 2.hours.ago

        index_sphinx

        ts_retry(2) do
          get :index, { categories: "film,health" }.merge(request_params)
          assigns(:articles).should eq [story1, story2].map(&:to_article)
        end
      end
    end

    context 'with date parameter' do
      before :all do
        setup_sphinx
      end

      after :all do
        teardown_sphinx
      end

      it "returns only stories from that date" do
        story_new  = create :news_story, published_at: Time.new(2013, 10, 16, 12)
        story_old1 = create :news_story, published_at: Time.new(2012, 10, 16, 0)
        story_old2 = create :news_story, published_at: Time.new(2012, 10, 16, 12)

        index_sphinx

        ts_retry(2) do
          get :index, { date: "2012-10-16" }.merge(request_params)
          assigns(:articles).should eq [story_old2, story_old1].map(&:to_article)
        end
      end

      it "returns a bad request if the date is an invalid format" do
        get :index, { date: "lolnope" }.merge(request_params)
        response.body.should match /Invalid Date/
      end
    end

    context 'with date range parameters' do
      before :all do
        setup_sphinx
      end

      after :all do
        teardown_sphinx
      end

      it 'returns only stories within that range' do
        story_new  = create :news_story, published_at: Time.new(2013, 10, 16, 12)
        story_old1 = create :news_story, published_at: Time.new(2012, 10, 16, 0)
        story_old2 = create :news_story, published_at: Time.new(2012, 10, 17, 12)

        index_sphinx

        ts_retry(2) do
          get :index, {
            start_date: "2012-10-16", end_date: "2012-10-17"
          }.merge(request_params)

          assigns(:articles).should eq [story_old2, story_old1].map(&:to_article)
        end
      end

      it 'uses now as the end time if none is specified' do
        Time.stub(:now) { Time.new(2013, 10, 17, 12) }

        story1      = create :news_story, published_at: 10.minutes.ago
        story2      = create :news_story, published_at: 10.hours.ago
        story_old   = create :news_story, published_at: Time.new(2012, 10, 17, 12)

        index_sphinx

        ts_retry(2) do
          get :index, {
            start_date: Time.now.strftime("%F")
          }.merge(request_params)

          assigns(:articles).should eq [story1, story2].map(&:to_article)
        end
      end

      it 'returns a bad request if the end_date is present but not start_date' do
        get :index, { end_date: "2013-10-16" }.merge(request_params)
        response.body.should match /start_date is required/
      end

      it 'returns a bad request if the date ranges are invalid formats' do
        get :index, { start_date: "lolnope" }.merge(request_params)
        response.body.should match /Invalid Date/
      end
    end

    context 'with types parameter' do
      sphinx_spec(num: 1)

      it "can take a comma-separated list of types" do
        ts_retry(2) do
          get :index, { types: "blogs,segments" }.merge(request_params)
          assigns(:classes).should eq [BlogEntry, ShowSegment]
          assigns(:articles).any? { |c| !%w{ShowSegment BlogEntry}.include?(c.original_object.class.name) }.should eq false
        end
      end

      it "is blogs,news,segments by default" do
        ts_retry(2) do
          get :index, request_params
          assigns(:articles).size.should eq @generated_content.select { |c|
            [BlogEntry, NewsStory, ShowSegment].include? c.class
          }.size
        end
      end
    end

    context 'with limit parameter' do
      sphinx_spec(num: 1)

      it "sanitizes the limit" do
        ts_retry(2) do
          get :index, { limit: "Evil Code" }.merge(request_params)
          assigns(:limit).should eq 0
          assigns(:articles).should eq []
        end
      end

      it "returns only LIMIT number of results" do
        ts_retry(2) do
          get :index, { limit: 1 }.merge(request_params)
          assigns(:articles).size.should eq 1
        end
      end

      it "sets the max limit to 40" do
        ts_retry(2) do
          get :index, { limit: 100 }.merge(request_params)
          assigns(:limit).should eq 40
        end
      end
    end

    context 'with the page parameter' do
      sphinx_spec(num: 1)

      it "sanitizes the page" do
        ts_retry(2) do
          get :index, { page: "Evil Code" }.merge(request_params)
          assigns(:page).should eq 1
        end
      end

      it "returns PAGE page of results" do
        ts_retry(2) do
          get :index, request_params
          third_obj = assigns(:articles)[2]

          get :index, { page: 3, limit: 1, types: "news,blogs,segments,shells" }.merge(request_params)
          assigns(:articles).should eq [third_obj].map(&:to_article)
        end
      end
    end

    context 'with the query parameter' do
      sphinx_spec(num: 1)

      it "returns results matching the query" do
        entry = create :blog_entry, headline: "Spongebob Squarepants!"
        index_sphinx

        ts_retry(2) do
          get :index, { query: "Spongebob+Squarepants" }.merge(request_params)
          assigns(:articles).should eq [entry].map(&:to_article)
        end
      end
    end
  end
end

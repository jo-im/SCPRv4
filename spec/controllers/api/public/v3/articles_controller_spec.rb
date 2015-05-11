require "spec_helper"

describe Api::Public::V3::ArticlesController, :indexing do
  request_params = {
    :format => :json
  }

  render_views

  describe "GET show" do
    it "finds the object if it exists" do
      entry = create :blog_entry
      get :show, { obj_key: entry.obj_key }.merge(request_params)
      assigns(:article).try(:obj_key).should eq entry.obj_key
      response.should render_template "show"
    end

    it "returns a 404 status if it does not exist" do
      # We need content, even if we aren't going to use it
      create :news_story
      get :show, { obj_key: "nope" }.merge(request_params)
      response.response_code.should eq 404
      JSON.parse(response.body)["error"]["message"].should eq "Not Found"
    end
  end

  describe "GET by_url" do
    it "finds the object if the URI matches" do
      entry = create :blog_entry
      get :by_url, { url: entry.public_url }.merge(request_params)
      assigns(:article).try(:obj_key).should eq entry.obj_key
      response.should render_template "show"
    end

    it "validates the URI, returning a bad request if not valid" do
      get :by_url, { url: '###' }.merge(request_params)
      response.response_code.should eq 400
      JSON.parse(response.body)["error"]["message"].should eq "Invalid URL"
    end

    it "returns a 404 if no object is found" do
      get :by_url, { url: "nope.com" }.merge(request_params)
      response.response_code.should eq 404
      JSON.parse(response.body)["error"]["message"].should eq "Not Found"
    end
  end

  describe "GET most_viewed" do
    it "returns the cached articles" do
      articles = create_list(:blog_entry, 2).map(&:to_article)
      Rails.cache.write("popular/viewed", articles)

      get :most_viewed, request_params
      assigns(:articles).map(&:obj_key).should eq articles.map(&:obj_key)
      response.body.should render_template "index"
    end

    it "returns an error if the cache is nil" do
      get :most_viewed, request_params
      assigns(:articles).should eq nil
      response.response_code.should eq 503
      JSON.parse(response.body)["error"]["message"].should match /Cache not warm/
    end
  end

  describe "GET most_commented" do
    it "returns the cached articles" do
      articles = create_list(:blog_entry, 2).map(&:to_article)
      Rails.cache.write("popular/commented", articles)

      get :most_commented, request_params
      assigns(:articles).map(&:obj_key).should eq articles.map(&:obj_key)
      response.body.should render_template "index"
    end

    it "returns an error if the cache is nil" do
      get :most_commented, request_params
      assigns(:articles).should eq nil
      response.response_code.should eq 503
      JSON.parse(response.body)["error"]["message"].should match /Cache not warm/
    end
  end

  describe "GET index" do
    context 'with the category parameter' do
      it 'only selects stories with the requested categories' do
        category1  = create :category, slug: "film"
        story1     = create :news_story,
          category: category1, published_at: 1.hour.ago

        category2  = create :category, slug: "health"
        story2     = create :news_story,
          category: category2, published_at: 2.hours.ago

        # Control - add these in to make sure we're *only* returning
        # stories with the requested categories
        category3  = create :category, slug: "watwat"
        story3     = create :news_story,
          category: category3, published_at: 1.hour.ago

        get :index, { categories: "film,health" }.merge(request_params)
        assigns(:articles).map(&:obj_key).should eq [story1, story2].map(&:obj_key)
      end
    end

    context "with tags" do
      it "filters by requested tags" do
        tag1 = create :tag, slug: "cool-tag"
        tag2 = create :tag, slug: "another-tag"
        tag3 = create :tag, slug: "nope-tag"

        story1 = build :news_story
        story1.tags = [tag1, tag2]
        story1.save!

        story2 = build :news_story
        story2.tags = [tag3]
        story2.save!

        get :index, { tags: "cool-tag,another-tag" }.merge(request_params)
        assigns(:articles).map(&:obj_key).should eq [story1.obj_key]
        response.body.should match tag1.title
        response.body.should match tag2.title
        response.body.should_not match tag3.title
      end
    end

    context 'with the date parameter' do
      it "selects stories only from that date" do
        story_new  = create :news_story, published_at: Time.zone.parse("2013-10-16 12:00:00")
        story_old1 = create :news_story, published_at: Time.zone.parse("2012-10-16 00:00:00")
        story_old2 = create :news_story, published_at: Time.zone.parse("2012-10-16 12:00:00")

        get :index, { date: "2012-10-16" }.merge(request_params)
        assigns(:articles).map(&:obj_key).should eq [story_old2, story_old1].map(&:obj_key)
      end

      it "returns a bad request if the date paramter is an invalid format" do
        get :index, { date: "lolnope" }.merge(request_params)
        JSON.parse(response.body)["error"]["message"].should match /Invalid Date/
      end
    end

    context 'with date range parameters' do
      it 'can filter by date range' do
        story_new  = create :news_story, published_at: Time.zone.parse("2013-10-16 12:00:00")
        story_old1 = create :news_story, published_at: Time.zone.parse("2012-10-16 12:00:00")
        story_old2 = create :news_story, published_at: Time.zone.parse("2012-10-17 12:00:00")

        get :index, {
          start_date: "2012-10-16", end_date: "2012-10-17"
        }.merge(request_params)

        assigns(:articles).map(&:obj_key).should eq [story_old2, story_old1].map(&:obj_key)
      end

      it 'uses now as the end time if none is specified' do
        Time.stub(:now) { Time.zone.local(2013, 10, 17, 12) }

        story1      = create :news_story, published_at: 10.minutes.ago
        story2      = create :news_story, published_at: 10.hours.ago
        story_old   = create :news_story, published_at: Time.zone.local(2012, 10, 17, 12)

        get :index, {
          start_date: Time.zone.now.strftime("%F")
        }.merge(request_params)

        assigns(:articles).map(&:obj_key).should eq [story1, story2].map(&:obj_key)
      end

      it 'returns a bad request if the end_date is present but not start_date' do
        get :index, { end_date: "2013-10-16" }.merge(request_params)
        JSON.parse(response.body)["error"]["message"].should match /start_date is required/
      end

      it 'returns a bad request if the date ranges are invalid formats' do
        get :index, { start_date: "lolnope" }.merge(request_params)
        JSON.parse(response.body)["error"]["message"].should match /Invalid Date/
      end
    end

    context 'with the types parameter' do
      before(:each) do
        [:show_segment,:blog_entry,:news_story,:content_shell].each { |t| create t }
      end

      it "can take a comma-separated list of types" do
        get :index, { types: "blogs,segments" }.merge(request_params)

        assigns(:articles).any? { |c|
          !%w{show_segment blog_entry}.include?(c.obj_class)
        }.should eq false
      end

      it "uses blogs,news,segments by default" do
        get :index, request_params
        assigns(:articles).size.should eq 3
      end
    end

    context 'with the limit parameter' do
      before(:each) do
        [:show_segment,:blog_entry,:news_story,:content_shell].each { |t| create t }
      end

      it "sanitizes the limit" do
        get :index, { limit: "Evil Code" }.merge(request_params)
        assigns(:limit).should eq 0
        assigns(:articles).should eq []
      end

      it "only returns LIMIT number of results" do
        get :index, { limit: 1 }.merge(request_params)
        assigns(:articles).size.should eq 1
      end

      it "sets the max limit to 40" do
        get :index, { limit: 100 }.merge(request_params)
        assigns(:limit).should eq 40
      end
    end

    context 'with the page paramter' do
      it "sanitizes the page" do
        get :index, { page: "Evil Code" }.merge(request_params)
        assigns(:page).should eq 1
      end

      it "returns PAGE page of results" do
        stories = create_list :news_story, 5

        get :index, { page: 3, limit: 1, types: "news,blogs,segments,shells" }.merge(request_params)

        assigns(:articles).map(&:obj_key).should eq [stories[2].obj_key]
      end
    end

    context 'with the query paramter' do
      it "returns results which match that query" do
        entry = create :blog_entry, headline: "Spongebob Squarepants!"
        get :index, { query: "Spongebob" }.merge(request_params)
        assigns(:articles).size.should eq 1
        assigns(:articles)[0].obj_key.should eq entry.obj_key
      end
    end
  end
end

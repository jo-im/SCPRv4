require "spec_helper"

describe CategoryController, :indexing do
  render_views

  before(:all) do
    create :show_segment
  end

  let(:category) { create :category }

  describe 'GET /news' do
    it 'sets @categories to all news categories' do
      category # touch
      create :news_story

      get :news
      assigns(:categories).should eq [category]
    end

    context 'with html request' do
      it 'gets the most recent article in news' do
        create :news_story, published_at: 1.month.ago, category: category
        create :news_story, published_at: 1.week.ago, category: category
        story3 = create :news_story, published_at: 1.day.ago, category: category

        get :news

        assigns(:top).should eq story3.to_article
      end

      it 'build sections for the categories, excluding the top article' do
        story1 = create :news_story, published_at: 1.month.ago, category: category
        story2 = create :news_story, published_at: 1.week.ago, category: category
        create :news_story, published_at: 1.day.ago, category: category

        get :news
        sections = assigns(:sections)

        sections.size.should eq 1
        sections.first.articles.should eq [story2, story1].map(&:to_article)
      end
    end

    context 'with xml request' do
      it "sets content to the most recent content in news" do
        story2 = create :news_story, published_at: 1.week.ago, category: category
        story3 = create :news_story, published_at: 1.day.ago, category: category

        get :news, format: :xml

        assigns(:content).to_a.should eq [story3, story2].map(&:to_article)

        response.should render_template 'category/news'
        response.header['Content-Type'].should match /xml/
        response.body.should match RSS_SPEC['xmlns:atom']
      end
    end
  end
end

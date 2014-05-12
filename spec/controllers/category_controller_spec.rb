require "spec_helper"

describe CategoryController do
  render_views

  let(:category) { create :category }

  describe 'GET /news' do
    it 'sets @categories to all news categories' do
      category # touch

      get :news
      assigns(:categories).should eq [category]
    end

    context 'with html request' do
      sphinx_spec

      it 'gets the most recent article in news' do
        story1 = create :news_story, published_at: 1.month.ago, category: category
        story2 = create :news_story, published_at: 1.week.ago, category: category
        story3 = create :news_story, published_at: 1.day.ago, category: category

        index_sphinx
        get :news

        ts_retry(2) do
          assigns(:top).should eq story3
        end
      end

      it 'build sections for the categories, excluding the top article' do
        story1 = create :news_story, published_at: 1.month.ago, category: category
        story2 = create :news_story, published_at: 1.week.ago, category: category
        story3 = create :news_story, published_at: 1.day.ago, category: category

        index_sphinx
        get :news
        sections = assigns(:sections)

        ts_retry(2) do
          sections.size.should eq 1
          sections.first.articles.should eq [story2].map(&:to_article)
        end
      end
    end

    context 'with xml request' do
      sphinx_spec

      it "sets content to the most recent content in news" do
        story1 = create :news_story, published_at: 1.month.ago, category: category
        story2 = create :news_story, published_at: 1.week.ago, category: category
        story3 = create :news_story, published_at: 1.day.ago, category: category

        index_sphinx
        get :news, format: :xml

        ts_retry(2) do
          assigns(:content).to_a.should eq [story3, story2]

          response.should render_template 'category/news'
          response.header['Content-Type'].should match /xml/
          response.body.should match RSS_SPEC['xmlns:atom']
        end
      end
    end
  end
end

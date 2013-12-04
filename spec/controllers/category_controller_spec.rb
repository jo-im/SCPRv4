require "spec_helper"

describe CategoryController do
  render_views

  let(:category_news) { create :category_news }
  let(:category_not_news) { create :category_not_news }

  describe 'GET /news' do
    it 'sets @categories to all news categories' do
      category_news && category_not_news # touch

      get :news
      assigns(:categories).should eq [category_news]
    end

    context 'with html request' do
      sphinx_spec

      it 'gets the most recent article in news' do
        story1 = create :news_story, published_at: 1.month.ago, category: category_news
        story2 = create :news_story, published_at: 1.week.ago, category: category_news
        story3 = create :news_story, published_at: 1.day.ago, category: category_not_news

        index_sphinx
        get :news

        ts_retry(2) do
          assigns(:top).should eq story2
        end
      end

      it 'build sections for the categories, excluding the top article' do
        story1 = create :news_story, published_at: 1.month.ago, category: category_news
        story2 = create :news_story, published_at: 1.week.ago, category: category_news
        story3 = create :news_story, published_at: 1.day.ago, category: category_not_news

        index_sphinx
        get :news
        sections = assigns(:sections)

        ts_retry(2) do
          sections.size.should eq 1
          sections.first.articles.should eq [story1].map(&:to_article)
        end
      end
    end

    context 'with xml request' do
      sphinx_spec

      it "sets content to the most recent content in news" do
        story1 = create :news_story, published_at: 1.month.ago, category: category_news
        story2 = create :news_story, published_at: 1.week.ago, category: category_news
        story3 = create :news_story, published_at: 1.day.ago, category: category_not_news

        index_sphinx
        get :news, format: :xml

        ts_retry(2) do
          assigns(:content).should eq [story2, story1]
          response.header['Content-Type'].should match /xml/
        end
      end
    end
  end

  describe 'GET /arts' do
    it 'sets @categories to all non-news categories' do
      category_news && category_not_news # touch

      get :arts
      assigns(:categories).should eq [category_not_news]
    end

    context 'with html request' do
      sphinx_spec

      it 'gets the most recent article in arts' do
        story1 = create :news_story, published_at: 1.month.ago, category: category_not_news
        story2 = create :news_story, published_at: 1.week.ago, category: category_not_news
        story3 = create :news_story, published_at: 1.day.ago, category: category_news

        index_sphinx
        sleep 2
        get :arts

        ts_retry(2) do
          assigns(:top).should eq story2
        end
      end

      it 'build sections for the categories, excluding the top article' do
        story1 = create :news_story, published_at: 1.month.ago, category: category_not_news
        story2 = create :news_story, published_at: 1.week.ago, category: category_not_news
        story3 = create :news_story, published_at: 1.day.ago, category: category_news

        index_sphinx
        get :arts
        sections = assigns(:sections)

        ts_retry(2) do
          sections.size.should eq 1
          sections.first.articles.should eq [story1].map(&:to_article)
        end
      end
    end

    context 'with xml request' do
      sphinx_spec

      it "sets content to the most recent content in arts" do
        story1 = create :news_story, published_at: 1.month.ago, category: category_not_news
        story2 = create :news_story, published_at: 1.week.ago, category: category_not_news
        story3 = create :news_story, published_at: 1.day.ago, category: category_news

        index_sphinx
        get :arts, format: :xml

        ts_retry(2) do
          assigns(:content).should eq [story2, story1]
          response.header['Content-Type'].should match /xml/
        end
      end
    end
  end
end

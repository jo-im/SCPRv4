require 'spec_helper'

describe CategoryArticle do
  describe '#simple_json' do
    it 'includes the obj_key and position' do
      story = build :news_story
      article = build :category_article, article: story

      json = article.simple_json
      json["id"].should eq story.obj_key
      json["position"].should eq 0
    end
  end

  it "only gets published articles" do
    article_unpublished = create :news_story, :draft
    category = create :category

    category_article = create :category_article,
      category: category, article: article_unpublished

    category_article.article(true).should eq nil
  end
end

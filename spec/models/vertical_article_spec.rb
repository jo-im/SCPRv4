require 'spec_helper'

describe VerticalArticle do
  describe '#simple_json' do
    it 'includes the obj_key and position' do
      story = build :news_story
      article = build :vertical_article, article: story

      json = article.simple_json
      json["id"].should eq story.obj_key
      json["position"].should eq 0
    end
  end

  it "only gets published articles" do
    article_unpublished = create :news_story, :draft
    vertical = create :vertical

    vertical_article = create :vertical_article,
      vertical: vertical, article: article_unpublished

    vertical_article.article(true).should eq nil
  end
end

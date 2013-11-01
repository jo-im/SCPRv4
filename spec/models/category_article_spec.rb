require 'spec_helper'

describe CategoryArticle do
  describe '#simple_json' do
    it 'includes the obj_key and position' do
      story = create :news_story
      article = create :category_article, article: story

      json = article.simple_json
      json["id"].should eq story.obj_key
      json["position"].should eq 0
    end
  end
end

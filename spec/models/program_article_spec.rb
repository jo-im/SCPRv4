require 'spec_helper'

describe ProgramArticle do
  describe '#simple_json' do
    it 'includes the obj_key and position' do
      story = build :news_story
      article = build :program_article, article: story

      json = article.simple_json
      json["id"].should eq story.obj_key
      json["position"].should eq 0
    end
  end

  it "only gets published articles" do
    article_unpublished = create :news_story, :draft
    program = create :kpcc_program

    program_article = create :program_article,
      kpcc_program: program, article: article_unpublished
    program_article.article(true).should eq nil
  end
end

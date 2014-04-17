require "spec_helper"

describe Concern::Associations::VerticalArticleAssociation do
  subject { build :test_class_story }
  it { should have_many(:vertical_articles) }

  describe 'destroying on unpublish' do
    it 'destroys the vertical_articles when unpublishing' do
      story = create :news_story, :published
      vertical = create :vertical

      vertical.vertical_articles.create(article: story)

      vertical.vertical_articles.count.should eq 1
      story.update_attributes(status: story.class.status_id(:draft))
      vertical.vertical_articles.count.should eq 0
    end
  end
end

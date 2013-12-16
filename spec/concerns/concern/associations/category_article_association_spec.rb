require "spec_helper"

describe Concern::Associations::CategoryArticleAssociation do
  subject { build :test_class_story }
  it { should have_many(:category_articles) }

  describe 'destroying on unpublish' do
    it 'destroys the category_articles when unpublishing' do
      story = create :news_story, :published
      category = create :category

      category.category_articles.create(article: story)

      category.category_articles.count.should eq 1
      story.update_attributes(status: story.class.status_id(:draft))
      category.category_articles.count.should eq 0
    end
  end
end



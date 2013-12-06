require "spec_helper"

describe Concern::Associations::IssueAssociation do
  describe 'story with many issues' do
    let(:category) { create :category, :is_news }
    let(:story) { build :test_class_story, :published, category: category }

    it 'has the proper associations' do
      story.should have_many(:article_issues)
      story.should have_many(:issues).through(:article_issues)
    end
  end

  describe "touching" do
    it "touches the article's issues on save" do
      story = create :test_class_story
      issue1 = create :issue
      issue2 = create :issue

      ts1 = issue1.updated_at
      ts2 = issue2.updated_at

      # I got 99 problems but a microsecond ain't one
      sleep 1

      story.issues = [issue1, issue2]
      story.save!

      issue1.reload.updated_at.should be > ts1
      issue2.reload.updated_at.should be > ts2
    end
  end
end

require "spec_helper"

describe Concern::Associations::IssueArticleAssociation do
  subject { TestClass::Story.new }

  describe '#issue_in_category' do
    let(:category) { create :category }
    let(:story) { build :test_class_story, :published, category: category }
    let(:common_issue) { create :issue }

    before :each do
      2.times { category.issues << create(:issue) }
      2.times { story.issues << create(:issue) }
      category.issues << common_issue
      story.issues << common_issue
    end

    it 'returns the articles first issue relevant to the category' do
      story.issue_in_category.should eq common_issue
    end

    it 'has the proper associations' do
      story.should have_many(:article_issues)
      story.should have_many(:issues).through(:article_issues)
    end

  end
end


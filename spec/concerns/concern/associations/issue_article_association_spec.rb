require "spec_helper"

describe Concern::Associations::IssueArticleAssociation do
  subject { TestClass::Story.new }

  describe '#issues_in_category' do
    let(:category) { create :category }
    let(:story) { build :test_class_story, :published, category: category }
    let(:common_issue) { create :issue }

    context 'story with many issues' do
      it 'has the proper associations' do
        story.should have_many(:article_issues)
        story.should have_many(:issues).through(:article_issues)
      end
    end

    context 'article and category share one issue' do
      before :each do
        4.times { category.issues << create(:issue) }
        2.times { story.issues << create(:issue) }
        category.issues << common_issue
        story.issues << common_issue
      end

      it 'returns an array with the article they both have in common' do
        story.issues_in_category.count.should eq 1
        story.issues_in_category.first.should eq common_issue
      end
    end

    context 'article and category have no issues in common' do
      before :each do
        4.times { category.issues << create(:issue) }
        2.times { story.issues << create(:issue) }
      end

      it 'returns an empty array' do
        story.issues_in_category.count.should eq 0
      end
    end

    context 'article and category that have no issues at all' do
      it 'returns an empty array' do
        story.issues_in_category.should eq []
      end
    end

  end
end


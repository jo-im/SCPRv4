require "spec_helper"

describe Concern::Associations::IssueAssociation do
  describe 'story with many issues' do
    let(:story) { build :test_class_story, :published, category: category }

    it 'has the proper associations' do
      story.should have_many(:article_issues)
      story.should have_many(:issues).through(:article_issues)
    end
  end
end

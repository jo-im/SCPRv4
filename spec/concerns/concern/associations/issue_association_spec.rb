require "spec_helper"

describe Concern::Associations::IssueAssociation do
  describe 'story with many issues' do
    let(:category) { create :category }
    let(:story) { build :test_class_story, :published, category: category }

    it 'has the proper associations' do
      story.should have_many(:article_issues)
      story.should have_many(:issues).through(:article_issues)
    end
  end

  describe 'touching' do
    let(:old_time) { 1.week.ago }
    let(:issues) { create_list :issue, 2, :is_active }

    before do
      issues.each { |i| i.update_column :updated_at, old_time }
    end

    it "touches the issues if the article is published" do
      story = create :test_class_story, :published
      story.issues = issues
      story.save!

      issues.each do |issue|
        issue.updated_at.should be > 10.seconds.ago
      end
    end

    it "does not touch the issues if the article is not published" do
      story = create :test_class_story, :unpublished
      story.issues = issues
      story.save!

      issues.each do |issue|
        issue.updated_at.should eq old_time
      end
    end

    it "touches the issues when going unpublished -> published" do
      story = create :test_class_story, :unpublished
      story.issues = issues
      story.save!

      issues.each do |issue|
        issue.updated_at.should eq old_time
      end

      story.publish

      issues.each do |issue|
        issue.updated_at.should be > 10.seconds.ago
      end
    end

    it "touches the issues when going published -> unpublished" do
      story = create :test_class_story, :published
      story.issues = issues
      story.save!

      # Reset the issues timestamp
      issues.each { |i| i.update_column :updated_at, old_time }

      story.update_attributes(status: TestClass::Story.status_id(:draft))

      issues.each do |issue|
        issue.updated_at.should be > 10.seconds.ago
      end
    end
  end
end

require "spec_helper"

describe Concern::Associations::CategoryAssociation do
  subject { build :test_class_story }
  it { should belong_to(:category) }

  let(:category) { create :category }
  let(:old_time) { 1.week.ago }

  before do
    category.update_column :updated_at, old_time
  end

  it "touches the category if the article is published" do
    story = create :test_class_story, :published, category: category

    # Close enough for government work.
    category.updated_at.should be > 10.seconds.ago
  end

  it "does not touch the category if the article is not published" do
    story = create :test_class_story, :unpublished, category: category
    category.updated_at.should eq old_time
  end

  it "touches the category when going unpublished -> published" do
    story = create :test_class_story, :unpublished, category: category
    story.publish

    category.updated_at.should be > 10.seconds.ago
  end

  it "touches the category when going published -> unpublished" do
    story = create :test_class_story, :published, category: category
    category.update_column :updated_at, old_time

    story.update_attributes(status: story.class.status_id(:draft))
    category.updated_at.should be > 10.seconds.ago
  end
end

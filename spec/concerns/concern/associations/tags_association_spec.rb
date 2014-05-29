require "spec_helper"

describe Concern::Associations::TagsAssociation do
  subject { create :test_class_story }

  it { should have_many :taggings }
  it { should have_many :tags }

  it "touches tags after save when publishing" do
    tag = create :tag
    tag.update_column(:updated_at, 1.month.ago)

    tag.reload.updated_at.should be < 10.minutes.ago

    story = build :test_class_story
    story.tags << tag
    story.save!

    tag.reload.updated_at.should be > 10.minutes.ago
  end
end

require "spec_helper"

describe Concern::Scopes::PublishedScope do
  it "orders by published_at desc" do
    t = Time.zone.now

    story1 = create :test_class_story, published_at: t - 3.days
    story2 = create :test_class_story, published_at: t - 2.days
    story3 = create :test_class_story, published_at: t - 1.day

    TestClass::Story.published.should eq [story3, story2, story1]
    TestClass::Story.published.to_sql.should match /order by #{TestClass::Story.table_name}.published_at desc/i
  end

  it "only grabs published content" do
    story_published   = create :test_class_story, :published
    story_unpublished = create :test_class_story, :pending
    TestClass::Story.published.should eq [story_published]
  end
end

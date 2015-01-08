require "spec_helper"

describe Job::HomepageCache do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:mid_priority] }

  describe "::perform" do
    it "scores and caches the homepage" do
      homepage = create :homepage, :published
      Rails.cache.read("views/home/sections").should eq nil

      Job::HomepageCache.perform

      Rails.cache.read("home/sections").should_not eq nil
    end
  end
end

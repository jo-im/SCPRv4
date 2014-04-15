require 'spec_helper'

describe "Episode page" do
  context "for external episode" do
    it "renders a list of segments" do
      episode = build :external_episode
      segment = build :external_segment, title: "Cool Segment!"
      episode.external_segments << segment
      episode.save!

      visit episode.public_url
      page.should have_content segment.title
    end
  end

  context "for KPCC episode" do
    it "renders a list of segments" do
      episode = build :show_episode
      segment = build :show_segment, headline: "Cool Segment!"
      episode.segments << segment
      episode.save!

      visit episode.public_url
      page.should have_content segment.headline
    end
  end
end

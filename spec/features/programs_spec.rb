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

describe "Program page" do
  context "for KPCC program" do
    it "shows the current episode if is_episodic is true" do
      program = create :kpcc_program, is_episodic: true
      episode = create :show_episode, show: program, headline: "xxCurrentEpisode--"

      visit program.public_path

      within "section.show-feature" do
        page.should have_content "xxCurrentEpisode--"
      end
    end

    it "shows the list of episodes if is_episodic is true" do
      program = create :kpcc_program, is_episodic: true

      episode = create :show_episode,
        :show           => program,
        :headline       => "xxCurrentEpisode--",
        :air_date       => 1.hour.ago

      episode = create :show_episode,
        :show           => program,
        :headline       => "xxLastEpisode--",
        :air_date       => 1.day.ago

      visit program.public_path

      within "section.show-episodes" do
        page.should have_content "xxLastEpisode--"
      end
    end
  end
end

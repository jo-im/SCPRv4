require "spec_helper"

describe Podcast do
  describe "#content" do
    context "for KpccProgram" do
      it "grabs episodes when item_type is episodes" do
        episode = create :show_episode
        create :audio, :direct, content: episode

        podcast = create :podcast, source: episode.show, item_type: "episodes"

        podcast.content.to_a.should eq [episode.to_article]
      end

      it "grabs segments when item_type is segments" do
        segment = create :show_segment
        create :audio, :direct, content: segment

        podcast = create :podcast, source: segment.show, item_type: "segments"

        podcast.content.to_a.should eq [segment.to_article]
      end
    end

    context "for ExternalProgram" do
      it "returns an empty array" do
        program = create :external_program
        podcast = create :podcast, source: program
        podcast.content.should eq []
      end
    end

    context "for Blog" do
      it "grabs entries" do
        entry = create :blog_entry
        create :audio, :direct, content: entry

        podcast = create :podcast, source: entry.blog

        podcast.content.to_a.should eq [entry.to_article]
      end
    end

    context "for Content" do
      it "grabs content" do
        story   = create :news_story, published_at: 1.days.ago
        entry   = create :blog_entry, published_at: 2.days.ago
        segment = create :show_segment, published_at: 3.days.ago

        [story, entry, segment].each do |content|
          create :audio, :direct, content: content
        end

        podcast = create :podcast, item_type: "content", source: nil

        podcast.content.to_a.should eq [story, entry, segment].map(&:to_article)
      end
    end
  end

  describe '#itunes_category' do
    it "Returns the text for the itunes category" do
      podcast = build :podcast, itunes_category_id: 1
      podcast.itunes_category.should eq "Arts"
    end
  end
end

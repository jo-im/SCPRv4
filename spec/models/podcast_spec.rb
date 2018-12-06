require "spec_helper"

describe Podcast do
  describe "#content", :indexing do
    context "for KpccProgram" do
      it "grabs episodes when item_type is episodes" do
        episode = create :show_episode
        create :audio, :direct, content: episode

        podcast = create :podcast, source: episode.show, item_type: "episodes"

        content = podcast.content
        content.length.should eq 1
        content.first.obj_key.should eq episode.obj_key

      end

      it "grabs segments when item_type is segments" do
        segment = create :show_segment
        create :audio, :direct, content: segment

        podcast = create :podcast, source: segment.show, item_type: "segments"

        content = podcast.content
        content.length.should eq 1
        content.first.obj_key.should eq segment.obj_key
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

        content = podcast.content
        content.length.should eq 1
        content.first.obj_key.should eq entry.obj_key
      end
    end

    context "for Content" do
      it "grabs content ordered by freshness" do
        story   = create :news_story, published_at: 1.days.ago
        entry   = create :blog_entry, published_at: 2.days.ago
        segment = create :show_segment, published_at: 3.days.ago

        content = [story, entry, segment]

        content.each do |content|
          create :audio, :direct, content: content
        end

        podcast = create :podcast, item_type: "content", source: nil

        # depending on the order in which tests are run, we could get content
        # from one of the other tests in this file. Pare down to our list
        # before comparing.

        content.map!(&:obj_key)

        podcast.content
        .map {|a| a.obj_key }
        .reject {|k| !content.include?(k) }
        .should eq content
      end

      it "doesn't grab content from NPR" do
        # Create 3 different content types
        story   = create :news_story, published_at: 1.days.ago
        entry   = create :blog_entry, published_at: 2.days.ago
        segment = create :show_segment, published_at: 3.days.ago

        # Add an NPR byline to the show segment
        byline  = create :byline, name: "John Doe | NPR", content: segment

        # For each of our content types, attach audio
        content = [story, entry, segment]
        content.each do |content|
          create :audio, :direct, content: content
        end

        podcast = create :podcast, item_type: "content", source: nil

        # Set the expectation that the show segment shouldn't be grabbed
        # because of the NPR byline we added to it earlier
        expected_content = [story, entry]
        expected_content.map!(&:obj_key)

        # Verify that the show segment isn't grabbed
        podcast.content
        .map {|a| a.obj_key }
        .reject {|k| !expected_content.include?(k)}
        .should eq expected_content
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

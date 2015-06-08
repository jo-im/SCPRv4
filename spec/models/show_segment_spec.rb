require "spec_helper"

describe ShowSegment do
  describe '#episodes' do
    it 'orders by status and air_date' do
      segment = build :show_segment
      segment.episodes.to_sql.should match /order by status desc,air_date desc/i
    end
  end

  describe "#episode" do
    it "uses the first episode the segment is associated with" do
      segment = create :show_segment
      episodes = create_list :show_episode, 3

      episodes.each do |ep|
        ep.segments << segment
      end

      segment.episode.should eq segment.episodes.first
    end
  end

  #------------------

  describe "#episode_segments" do
    it "uses the other segments from the episode if episodes exist" do
      episode = create :show_episode
      segments = create_list :show_segment, 3
      episode.segments = segments

      episode.segments.last.episode_segments.should eq episode.segments.first(3)
    end

    it "uses the 5 latest segments from its program if no episodes exist" do
      program = create :kpcc_program
      create_list :show_segment, 7, show: program
      program.segments.published.last.episode_segments.should eq program.segments.published.first(5)
      program.segments.published.first.episode_segments.should eq program.segments.published[1..5]
    end
  end

  #------------------

  describe "#byline_extras" do
    it "is an array with the show's title" do
      segment = build :show_segment
      segment.byline_extras.should eq [segment.show.title]
    end
  end

  describe '#to_article' do
    it 'makes a new article' do
      segment = build :show_segment
      segment.to_article.should be_a Article
    end
  end

  describe '#to_abstract' do
    it 'makes a new abstract' do
      segment = build :show_segment
      segment.to_abstract.should be_a Abstract
    end
  end
end

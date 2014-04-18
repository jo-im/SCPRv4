require "spec_helper"

describe ShowSegment do
  describe '#episodes' do
    it 'orders by air_date' do
      segment = build :show_segment
      segment.episodes.to_sql.should match /order by air_date/i
    end
  end

  describe "#episode" do
    it "uses the first episode the segment is associated with" do
      segment = create :show_segment
      episodes = create_list :show_episode, 3
      episodes.each { |episode| create :show_rundown, episode: episode, content: segment }
      segment.episode.should eq segment.episodes.first
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

  describe '#to_episode' do
    it 'is a lame workaround' do
      segment = build :show_segment
      segment.to_episode.should be_a Episode
      segment.to_episode.segments.should eq Array(segment) # lol
    end
  end
end

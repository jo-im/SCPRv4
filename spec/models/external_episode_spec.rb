require 'spec_helper'

describe ExternalEpisode do
  describe '#external_episode_segments' do
    it 'orders by position' do
      episode = build :external_episode
      episode.external_episode_segments.to_sql.should match /order by position/i
    end
  end

  describe '#external_segments' do
    it 'orders by position' do
      episode = build :external_episode
      episode.segments.to_sql.should match /order by position/i
    end
  end

  describe '::for_air_date' do
    it 'matches the dates' do
      t = Time.zone.now.yesterday
      episode = create :external_episode, air_date: t
      ExternalEpisode.for_air_date(t).should eq [episode]
    end
  end

  describe '#to_episode' do
    it 'turns it into an episode' do
      episode = build :external_episode
      episode.to_episode.should be_a Episode
    end
  end

  describe '#to_article' do
    it "turns the episode into an article" do
      episode = build :external_episode
      episode.to_article.should be_a Article
    end
  end

  describe 'expired episodes' do
    program = nil
    expired_episode = nil
    before :each do
      program = create :external_program, :from_rss, air_status: "onair", days_to_expiry: 3
      5.times do
        program.episodes << create(:external_episode, air_date: Time.now)
      end
      program.episodes << (expired_episode = create(:external_episode, air_date: 4.days.ago))
    end
    context 'has days_to_expiry timestamp' do
      it "only returns expired episodes" do
        expired_eps = program.episodes.expired
        expect(expired_eps.count).to eq(1)
        expect(expired_episode).to eq(program.episodes.order("air_date DESC").last)
      end
    end
    context 'has no days_to_expiry timestamp' do
      it 'returns no episodes' do
        program.update days_to_expiry: nil
        expect(program.episodes.expired).to be_empty
      end
    end
  end

end

require 'spec_helper'

describe Concern::Associations::EpisodeRundownAssociation do
  it 'updates the episode when the object has changed' do

    episode = nil
    segment = nil
    first_timestamp = nil

    Timecop.freeze(Date.parse('2015-08-13')) do
        episode       = create :show_episode
        segment       = create :show_segment
        segment.episodes << episode
        episode.reload
        first_timestamp = episode.updated_at
    end

    Timecop.freeze(Date.parse('2015-08-14')) do
        segment.update body: "updated body"
    end

    expect(episode.reload.updated_at).to be > first_timestamp
  end
end

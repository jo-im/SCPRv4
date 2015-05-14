class ExternalEpisodeSegment < ActiveRecord::Base
  belongs_to :episode, class_name: :ExternalEpisode, foreign_key: "external_episode_id"
  belongs_to :segment, class_name: :ExternalSegment, foreign_key: "external_segment_id"
end

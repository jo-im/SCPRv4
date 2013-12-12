ThinkingSphinx::Index.define :show_episode, with: :active_record do
  indexes headline
  indexes body

  has show.id, as: :program
  has air_date
  has status
  has published_at
  has updated_at

  # For podcasts
  join audio
  has "COUNT(DISTINCT #{Audio.table_name}.id) > 0",
    :type   => :boolean,
    :as     => :has_audio

  # Required attributes for ContentBase.search
  # For ShowEpisode, this is needed just for the
  # podcast feed.
  has air_date, as: :public_datetime
  has "#{ShowEpisode.table_name}.status = #{ShowEpisode.status_id(:live)}",
    :type   => :boolean,
    :as     => :is_live
end

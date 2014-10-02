class MoveSegmentsToEpisodes < ActiveRecord::Migration
  def up
    add_column :shows_episode, :original_segment_id, :integer
    add_index :shows_episode, :original_segment_id

    KpccProgram.where(is_segmented: false).each do |program|
      program.segments.each do |segment|
        episode = ShowEpisode.new(
          show_id: segment.show_id,
          headline: segment.headline,
          teaser: segment.teaser,
          body: segment.body,
          status: segment.status,
          published_at: segment.published_at,
          asset_display_id: segment.asset_display_id,
          air_date: segment.published_at
        )

        %w[
          audio
          assets
          bylines
          outgoing_references
          incoming_references
          related_links
          edition_slots
          alarm
        ].each do |assoc|
          episode.send("#{assoc}=", segment.send(assoc))
        end

        episode.original_segment_id = segment.id

        begin
          episode.save!
        rescue => e
          puts "ERROR: #{segment.obj_key}: #{e}"
        end
      end
    end
  end

  def down; end
end

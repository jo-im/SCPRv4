class AddExternalPodcastIdToPodcasts < ActiveRecord::Migration
  def up
    add_column :podcasts, :external_podcast_id, :string, limit: 255
  end

  def down
    remove_column :podcasts, :external_podcast_id
  end
end

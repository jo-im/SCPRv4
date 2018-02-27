class AddShortHeadlineToShowEpisodes < ActiveRecord::Migration
  def change
    add_column :shows_episode, :short_headline, :string, length: 255
  end
end

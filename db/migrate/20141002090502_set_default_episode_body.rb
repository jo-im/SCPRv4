class SetDefaultEpisodeBody < ActiveRecord::Migration
  def change
    ShowEpisode.find_each do |e|
      if e.body.nil?
        e.update_column(:body, e.teaser)
      end
    end
  end
end

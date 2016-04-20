class ClearDuplicateExternalEpisodes < ActiveRecord::Migration
  def up
    ExternalEpisode.where.not(id: ExternalEpisode.select("MAX(id) as id").group([:title, :external_program_id]).pluck(:id)).destroy_all
  end
  def down
  end
end

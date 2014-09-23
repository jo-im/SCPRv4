class RemoveMissedItBucketIdFromProgramsKpccprogram < ActiveRecord::Migration
  def change
    remove_column :programs_kpccprogram, :missed_it_bucket_id, :integer
  end
end

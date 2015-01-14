class AddSoftStartAtToSchedule < ActiveRecord::Migration
  def change
    add_column :recurring_schedule_rules, :soft_start_offset, :integer, :null => true
    add_column :schedule_occurrences, :soft_starts_at, :datetime, :null => true
  end
end

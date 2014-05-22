class AddNoteForManualEntry < ActiveRecord::Migration
  def up
    races = [
      "lausd.d1",
      "lb_mayor",
      "lac_sheriff",
      "lac_supervisor.d3"
    ]

    races.each do |key|
      dp = DataPoint.where(data_key: key).first
      dp.update_attribute(:notes, dp.notes + "; MANUAL ENTRY")
    end
  end

  def down; end
end

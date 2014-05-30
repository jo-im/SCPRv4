class AddNoteForManualEntry < ActiveRecord::Migration
  def up
    races = [
      "lausd.d1",
      "lb_mayor",
      "lac_sheriff",
      "lac_supervisor.d3"
    ]

    races.each do |key|
      DataPoint.where("data_key like (?)", "#{key}%").each do |dp|
        dp.update_attribute(:notes, dp.notes + "; MANUAL ENTRY")
      end
    end
  end

  def down; end
end

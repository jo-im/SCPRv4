class ChangeArchiveToHiddenOnPrograms < ActiveRecord::Migration
  def up
    KpccProgram.where(air_status: "archive").update_all air_status: "hidden"
    ExternalProgram.where(air_status: "archive").update_all air_status: "hidden"
  end
  def down
    "sorry, amigo"
  end
end

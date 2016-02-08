class MoveForumFlatpagesToInPersonTemplate < ActiveRecord::Migration
  def up
    Flatpage.where(template: "forum").update_all(template: "kpcc_in_person")
  end
  def down
    Flatpage.where(template: "kpcc_in_person").update_all(template: "forum")
  end
end

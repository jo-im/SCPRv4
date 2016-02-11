class PopulatePmpUsersAndCaliforniaCountsGroup < ActiveRecord::Migration
  def up
    kqed      = PmpUser.where(title: "KQED", guid: "9f343a35-f2cb-4ff1-abfc-5f53f440b417").first_or_create
    cap_radio = PmpUser.where(title: "CapRadio", guid: "47414e39-4efc-4660-a547-9d8e9611f84e").first_or_create
    kpbs      = PmpUser.where(title: "KPBS", guid: "51396e0f-4ba6-4a07-b4f3-94f5681df4e7").first_or_create
    group     = PmpGroup.where(title: "California Counts").first_or_create
    group.pmp_users << [kqed, cap_radio, kpbs]
    group.save
    group.publish
  end
  def down
    PmpUser.where(title: ["KQED", "CapRadio", "KPBS"]).delete_all
    PmpGroup.where(title: "California Counts").delete_all
  end
end

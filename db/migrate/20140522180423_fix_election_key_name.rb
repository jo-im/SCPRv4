class FixElectionKeyName < ActiveRecord::Migration
  def up
    DataPoint.where(group_name: "elections-june2014").update_all(group_name: "election-june2014")
  end

  def down; end
end

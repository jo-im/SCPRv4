class RemoveJune2014DataPoints < ActiveRecord::Migration
  def up
    DataPoint.delete_all :group_name => 'election-june2014'
  end

  def down
    # mmmmmm nope.
  end
end

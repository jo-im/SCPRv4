class RemoveNov2014DataPoints < ActiveRecord::Migration
  def up
    DataPoint.delete_all :group_name => 'election-nov2014'
  end

  def down
    # there is no going back.
  end
end

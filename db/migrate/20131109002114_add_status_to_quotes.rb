class AddStatusToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :status, :integer
  end
end

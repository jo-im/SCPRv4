class AddAbstractSourceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :abstract_source, :string
  end
end

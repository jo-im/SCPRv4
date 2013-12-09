class AddTitleToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :title, :string
  end
end

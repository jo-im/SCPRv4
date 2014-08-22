class AddSlugToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :slug, :string
    add_index :editions, :slug
  end
end

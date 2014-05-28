class AddVerticalFk < ActiveRecord::Migration
  def change
    add_column :category_articles, :vertical_id, :integer
    add_index :category_articles, :vertical_id

    add_column :category_issues, :vertical_id, :integer
    add_index :category_issues, :vertical_id

    add_column :category_reporters, :vertical_id, :integer
    add_index :category_reporters, :vertical_id
  end
end

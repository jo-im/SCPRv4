class CreateCategoryReporters < ActiveRecord::Migration
  def change
    create_table :category_reporters do |t|
      t.references :category
      t.references :bio

      t.timestamps
    end
    add_index :category_reporters, :category_id
    add_index :category_reporters, :bio_id
  end
end

class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :title
      t.string :slug
      t.text :description
      t.boolean :is_active

      t.timestamps
    end

    add_index :issues, :title
    add_index :issues, :slug
    add_index :issues, :is_active
    add_index :issues, :created_at
  end
end

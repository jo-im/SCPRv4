class CreateListItems < ActiveRecord::Migration
  def change
    create_table :list_items do |t|
      t.references :list, index: true
      t.references :item, polymorphic: true, index: true
      t.integer    :position, default: 0
      t.timestamps null: false
    end
  end
end

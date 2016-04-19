class CreateBroadcastContents < ActiveRecord::Migration
  def change
    create_table :broadcast_contents do |t|
      t.string :title
      t.text :script
      t.references :content, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end

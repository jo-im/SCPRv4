class CreateBroadcastContents < ActiveRecord::Migration
  def change
    create_table :broadcast_contents do |t|
      t.string :headline
      t.text :body
      t.references :content, polymorphic: true, index: true
      t.integer :status, limit: 4, null: false
      t.timestamps null: false
    end
  end
end

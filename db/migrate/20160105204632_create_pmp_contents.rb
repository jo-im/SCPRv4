class CreatePmpContents < ActiveRecord::Migration
  def change
    create_table :pmp_contents do |t|
      t.references :content, polymorphic: true
      t.string :guid
      t.timestamps null: false
    end
  end
end

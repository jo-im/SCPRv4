class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :email, index: true
      t.boolean :email_sent
      t.string :first_name
      t.string :last_name
      t.string :name
      t.boolean :pfs_selected
      t.integer :pledge_amount
      t.string :pledge_id
      t.string :pledge_token, index: true
      t.string :pledge_type
      t.string :record_source
      t.integer :views_left
      t.string :member_id, index: true

      t.timestamps null: false
    end
  end
end

class AddEmailAttributesToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :send_email, :boolean, default: true
    add_column :editions, :email_sent, :boolean, default: false
    add_index :editions, :email_sent
  end
end

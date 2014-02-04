class RemoveSendEmailFromEdition < ActiveRecord::Migration
  def up
    remove_column :editions, :send_email
  end

  def down
    add_column :editions, :send_email, :boolean
  end
end

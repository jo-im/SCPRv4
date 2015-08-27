class AddSpecificEmailSentColumnsToEdition < ActiveRecord::Migration
  def change
    rename_column :editions, :email_sent, :shortlist_email_sent
    add_column :editions, :monday_shortlist_email_sent, :boolean, default: false
  end
end

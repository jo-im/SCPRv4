class AddAttemptsMadeToEloquaEmails < ActiveRecord::Migration
  def change
    add_column :eloqua_emails, :attempts_made, :integer, default: 0
  end
end

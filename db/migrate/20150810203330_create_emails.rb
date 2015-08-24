class CreateEmails < ActiveRecord::Migration
  def change
    create_table :eloqua_emails do |t|
      t.string :name
      t.string :description
      t.string :subject
      t.string :email
      t.string :html_template
      t.string :plain_text_template
      t.belongs_to :emailable
      t.string :emailable_type
      t.boolean :email_sent, default: false
      t.string :email_type

      t.timestamps null: false
    end
  end
end

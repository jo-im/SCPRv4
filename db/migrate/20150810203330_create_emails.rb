class CreateEmails < ActiveRecord::Migration
  def change
    create_table :eloqua_emails do |t|
      t.string :name
      t.string :description
      t.string :subject
      t.string :email
      t.text :html_body
      t.text :plain_text_body
      t.belongs_to :emailable
      t.string :emailable_type
      t.boolean :email_sent, default: false
      t.string :email_type

      t.timestamps null: false
    end
  end
end

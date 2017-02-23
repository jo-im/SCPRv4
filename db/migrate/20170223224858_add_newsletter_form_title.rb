class AddNewsletterFormTitle < ActiveRecord::Migration
  def change
    add_column :programs_kpccprogram, :newsletter_form_heading, :string
  end
end

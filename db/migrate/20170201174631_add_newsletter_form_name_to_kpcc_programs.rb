class AddNewsletterFormNameToKpccPrograms < ActiveRecord::Migration
  def change
    add_column :programs_kpccprogram, :newsletter_form_name, :string
  end
end

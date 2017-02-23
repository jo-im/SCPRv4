class AddNewsletterSignupDescriptionToPrograms < ActiveRecord::Migration
  def change
    add_column :programs_kpccprogram, :newsletter_form_caption, :string
  end
end

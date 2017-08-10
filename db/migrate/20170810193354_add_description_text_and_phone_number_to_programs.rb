class AddDescriptionTextAndPhoneNumberToPrograms < ActiveRecord::Migration
  def change
    add_column :programs_kpccprogram, :description_text, :text
    add_column :programs_kpccprogram, :phone_number, :string
  end
end

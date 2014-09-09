class AddQuoteRefToProgramKpccPrograms < ActiveRecord::Migration
  def change
    add_reference :programs_kpccprogram, :quote, index: true
  end
end

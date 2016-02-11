class AddTitleToPmpContent < ActiveRecord::Migration
  def change
    add_column :pmp_contents, :title, :string
  end
end

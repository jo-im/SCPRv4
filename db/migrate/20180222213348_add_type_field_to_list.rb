class AddTypeFieldToList < ActiveRecord::Migration
  def change
    add_column :lists, :content_type, :string
  end
end


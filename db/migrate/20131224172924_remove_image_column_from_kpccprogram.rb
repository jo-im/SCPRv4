class RemoveImageColumnFromKpccprogram < ActiveRecord::Migration
  def up
    remove_column :programs_kpccprogram, :image
  end

  def down
    add_column :programs_kpccprogram, :image, :string
  end
end

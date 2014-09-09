class RemoveTwitterHandleFromPrograms < ActiveRecord::Migration
  def change
    remove_column :programs_kpccprogram, :twitter_handle, :string
    remove_column :external_programs, :twitter_handle, :string
  end
end

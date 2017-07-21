class MakeSettingsValuesBigger < ActiveRecord::Migration
  def up
    change_column :settings, :value, :text
  end
  def down
    change_column :settings, :value, :string
  end
end

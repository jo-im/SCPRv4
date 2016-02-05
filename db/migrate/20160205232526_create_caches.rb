class CreateCaches < ActiveRecord::Migration
  def change
    create_table :caches do |t|
      t.string :key, index: true
      t.string :value
    end
  end
end

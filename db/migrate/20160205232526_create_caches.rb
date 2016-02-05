class CreateCaches < ActiveRecord::Migration
  def change
    create_table :caches do |t|
      t.string :key, index: true
      t.text :value, limit: 4294967295
    end
  end
end

class MakeTagBelongToParent < ActiveRecord::Migration
  def up
    change_table :tags do |t|
      t.references :parent, polymorphic: true
    end
  end
  def down
    change_table :tags do |t|
      t.remove_references :parent, polymorphic: true
    end
  end
end

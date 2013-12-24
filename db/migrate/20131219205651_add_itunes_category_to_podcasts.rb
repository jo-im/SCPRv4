class AddItunesCategoryToPodcasts < ActiveRecord::Migration
  def change
    add_column :podcasts, :itunes_category_id, :integer
  end
end

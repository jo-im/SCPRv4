class AddFeaturedInteractiveStyleToCategory < ActiveRecord::Migration
  def change
    add_column :contentbase_category, :featured_interactive_style, :integer
  end
end

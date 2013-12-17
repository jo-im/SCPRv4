class RenameFeaturedInteractiveStyleColumn < ActiveRecord::Migration
  def change
    rename_column :contentbase_category, :featured_interactive_style, :featured_interactive_style_id
  end
end

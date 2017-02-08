class AddSlugToLandingPage < ActiveRecord::Migration
  def change
    if !column_exists?(:landing_pages, :slug)
      add_column :landing_pages, :slug, :string
    end
  end
end

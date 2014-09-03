class PopulateEditionSlugs < ActiveRecord::Migration
  def change
    Edition.all.each do |edition|
      if edition.title.present?
        edition_slug = edition.title.split('.').join('').parameterize
        edition.slug = edition_slug
        edition.save
      end
    end
  end
end

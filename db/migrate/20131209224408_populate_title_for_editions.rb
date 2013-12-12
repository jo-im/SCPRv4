class PopulateTitleForEditions < ActiveRecord::Migration
  def up
    Edition.published.each do |edition|
      if [6, 0].include?(edition.published_at.day)
        edition.update_column(:title, "Weekend Reads")
      elsif edition.published_at.hour >= 12
        edition.update_column(:title, "P.M. Edition")
      else
        edition.update_column(:title, "A.M. Edition")
      end
    end
  end

  def down
    # Validations
  end
end

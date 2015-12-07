class PopulateBeatTags < ActiveRecord::Migration

  TAG_NAMES = [
    "Public Safety",
    "SoCal Economy",
    "SoCal Politics",
    "The Social Safety Net",
    "Vets",
    "Workplace",
    "Changing Neighborhoods & Affordability",
    "Communting",
    "Immigration 3.0",
    "Infrastructure",
    "Orange County"
  ]

  def up
    TAG_NAMES.each do |tag_name|
      Tag.create title: tag_name, tag_type: "Beat"
    end
  end

  def down
    Tag.where(title: TAG_NAMES, tag_type: "Beat").destroy_all
  end
end

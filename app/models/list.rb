class List < ActiveRecord::Base
  outpost_model
  has_status

  has_many :items,
    -> { order('position').includes(:item) },
    class_name: "ListItem"

  accepts_json_input_for :items

  validates :title, presence: true

  scope :published, ->(){ 
    where("
      (start_time IS NULL AND end_time IS NULL)
      OR
      (start_time < ? AND (end_time > ? OR end_time IS NULL))
      OR
      ((start_time < ? OR start_time IS NULL) AND end_time > ?)
    ", Time.zone.now, Time.zone.now, Time.zone.now, Time.zone.now)
    .where(status: 5)
  }

  status :draft do |s|
    s.id = 0
    s.text = "Draft"
    s.unpublished!
  end

  status :live do |s|
    s.id = 5
    s.text = "Live"
    s.published!
  end

  def build_item_association(item_hash, item)
    item_hash.delete "asset_scheme"
    attrs = item_hash.merge({
      item: item,
      list: self,
      position: item_hash["position"].to_i
    })
    ListItem.new(attrs) if item.published?
  end

end

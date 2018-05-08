class List < ActiveRecord::Base

  CONTENT_TYPES = {
    "article" => ["NewsStory", "BlogEntry", "ShowSegment", "Event", "ContentShell"],
    "program" => ["KpccProgram", "ExternalProgram"],
    "episode" => ["ShowEpisode"]
  }

  outpost_model
  has_status

  include Concern::Associations::CategoryAssociation

  has_many :items,
    -> { order('position').includes(:item) },
    class_name: "ListItem"

  accepts_json_input_for :items

  validates :title, presence: true

  scope :published, ->(){
    where(status: 5)
  }

  scope :visible, ->(){
    published.where("
      (starts_at IS NULL AND ends_at IS NULL)
      OR
      (starts_at < ? AND (ends_at > ? OR ends_at IS NULL))
      OR
      ((starts_at < ? OR starts_at IS NULL) AND ends_at > ?)
    ", Time.zone.now, Time.zone.now, Time.zone.now, Time.zone.now)
  }

  before_save :sanitize_context, :enforce_content_type

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

  def deduped_category_items
    self.category.content({
      page: 1,
      per_page: 16,
      exclude: ApplicationHelper.latest_headlines({ limit: 16 })
    })
  end

  private

  def sanitize_context
    self.context = (self.context || "").split(",").map(&:strip).join(",")
  end

  def enforce_content_type
    model_names = CONTENT_TYPES[content_type]
    items.where.not(item_type: model_names).destroy_all
  end

end
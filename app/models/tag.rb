class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Associations::RelatedContentAssociation

  validates :slug, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true

  has_many :taggings, dependent: :destroy

  has_many :better_homepages, through: :taggings, source: :taggable, source_type: "BetterHomepage"

  belongs_to :parent, polymorphic: true

  after_commit :update_better_homepage_cache, if: :on_current_homepage?

  TYPES = ["Beat", "Series", "Keyword"]

  def taggables(options={})
    ContentBase.search({ with: { "tags.slug" => self.slug } }.reverse_merge(options))
  end

  def articles(options={})
    taggables(options)
  end

  def pmp_alias
    super || slug
  end

  def pmp_alias= new_alias
    super unless pmp_alias == new_alias
  end

  def public_path *args
    "/topics/#{slug}" if slug
  end

  def featured_content omit=[]
    # omit is a list of model records to exclude from the results,
    # probably coming from a homepage object
    related_omissions = omit.map{|m| "(related_type NOT LIKE '#{m.class}' AND related_id <> #{m.id})"}.join(" AND ")
    tagging_omissions = omit.map{|m| "(taggable_type NOT LIKE '#{m.class}' AND taggable_id <> #{m.id})"}.join(" AND ")
    if outgoing_references.count > 2
      outgoing_references
        .order("position ASC")
        .where(related_omissions)
        .limit(3).map(&:related)
    elsif taggings.count > 2
      taggings
        .order("created_at DESC")
        .where(tagging_omissions)
        .limit(10)
        .map(&:taggable)
        .select{|a| a.try(:public_datetime)}
        .first(3)
    else
      []
    end
  end

  def update_better_homepage_cache
    if homepage = homepage_if_on_current
      homepage.touch
    end
  end

  def on_current_homepage?
    better_homepages.current.include? BetterHomepage.current.last
  end

  def homepage_if_on_current
    homepage = BetterHomepage.current.last
    if better_homepages.current.include? homepage
      homepage
    end
  end

  def _destroy_homepage_contents
    self.homepage_contents.clear
  end

  class << self
    def by_type
      list = []
      TYPES.each do |tag_type|
        list << OpenStruct.new(name: tag_type, tags: where(tag_type: tag_type))
      end
      list
    end
  end

end

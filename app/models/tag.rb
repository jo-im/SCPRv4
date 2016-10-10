class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Associations::RelatedContentAssociation

  validates :slug, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true

  has_many :taggings, dependent: :destroy

  belongs_to :parent, polymorphic: true

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

  def public_path
    "/topics/#{slug}" if slug
  end

  def featured_content omit=[]
    # omit is a list of model records to exclude from the results,
    # probably coming from a homepage object
    related_omissions = omit.map{|m| "(related_type NOT LIKE '#{m.class}' AND related_id <> #{m.id})"}.join(" AND ")
    tagging_omissions = omit.map{|m| "(taggable_type NOT LIKE '#{m.class}' AND taggable_id <> #{m.id})"}.join(" AND ")
    if outgoing_references.count > 3
      outgoing_references.order("position ASC")
        .where(related_omissions)
        .limit(3).map(&:related).map(&:to_article)
    elsif taggings.count > 3
      taggings.order("created_at DESC")
        .where(tagging_omissions)
        .limit(3).map(&:taggable).map(&:to_article)
    end
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

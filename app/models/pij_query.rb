class PijQuery < ActiveRecord::Base
  self.table_name = 'pij_query'
  outpost_model
  has_secretary
  has_status


  include Concern::Scopes::SinceScope
  include Concern::Scopes::PublishedScope
  include Concern::Associations::AssetAssociation
  include Concern::Associations::RelatedLinksAssociation
  include Concern::Associations::RelatedContentAssociation
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Associations::HomepageContentAssociation
  include Concern::Associations::MissedItContentAssociation
  include Concern::Associations::VerticalArticleAssociation
  include Concern::Associations::ProgramArticleAssociation
  include Concern::Validations::SlugValidation
  include Concern::Callbacks::GenerateSlugCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::CacheExpirationCallback
  include Concern::Callbacks::TouchCallback


  self.public_route_key = "pij_query"

  QUERY_TYPES = [
    ["Evergreen", "evergreen"],
    ["News", "news"],
    ["Internal (not listed)", "utility"]
  ]


  status :hidden do |s|
    s.id = 0
    s.text = "Hidden"
    s.unpublished!
  end

  status :pending do |s|
    s.id = 3
    s.text = "Pending"
    s.pending!
  end

  status :live do |s|
    s.id = 5
    s.text = "Live"
    s.published!
  end


  validates :slug, uniqueness: true
  validates :headline, presence: true
  validates :teaser, presence: true
  validates :body, presence: true
  validates :query_type, presence: true
  validates :pin_query_id, presence: true
  validates :status, presence: true


  def publish
    self.update_attributes(status: self.class.status_id(:live))
  end


  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => "KPCC Asks: " + self.headline,
      :short_title        => "KPCC Asks: " + self.headline,
      :public_datetime    => self.published_at,
      :teaser             => self.teaser,
      :body               => self.body,
      :assets             => self.assets,
      :byline             => "KPCC",
      :edit_url           => self.admin_edit_url
    })
  end


  #------------

  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :slug           => self.persisted_record.slug,
      :trailing_slash => true
    }
  end
end

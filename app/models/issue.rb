class Issue < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Validations::SlugValidation
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Associations::TagsAssociation

  self.public_route_key = 'issue'

  scope :active, -> { where(is_active: true) }

  has_many :article_issues, dependent: :destroy

  # This association is here so the join records will be destroyed
  # if the issue is destroyed. It also helps break cached on the
  # verticals when an issue is updated.
  has_many :vertical_issues, dependent: :destroy
  has_many :verticals, through: :vertical_issues

  after_commit :touch_verticals

  validates :title, presence: true
  validates :slug, uniqueness: true
  validates :description, presence: true


  def route_hash
    return {} if !self.persisted?
    { slug: self.persisted_record.slug }
  end

  def articles
    @articles ||= self.article_issues.includes(:article)
      .select(&:article).map { |a| a.article.to_article }
      .sort { |a, b| b.public_datetime <=> a.public_datetime }
  end


  private

  def touch_verticals
    self.verticals.each(&:touch)
  end
end

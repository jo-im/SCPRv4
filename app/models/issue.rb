class Issue < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Validations::SlugValidation
  include Concern::Callbacks::SphinxIndexCallback

  ROUTE_KEY = 'issue'

  scope :active, -> { where(is_active: true) }

  has_many :article_issues, dependent: :destroy
  has_many :category_issues, dependent: :destroy
  has_many :categories, through: :category_issues

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
end

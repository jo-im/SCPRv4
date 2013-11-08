class Issue < ActiveRecord::Base
  outpost_model
  has_secretary
  attr_accessible :description, :is_active, :slug, :title
  include Concern::Validations::SlugValidation

  ROUTE_KEY = 'root_slug'

  scope :active, -> { where(is_active: true) }

  has_many :article_issues
  has_many :category_issues
  has_many :categories, through: :category_issues

  validates :title, presence: true
  validates :slug, uniqueness: true
  validates :description, presence: true

  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end

  def articles
    @articles ||= self.article_issues.includes(:article).map { |a| a.article.to_article }
  end

end

class Issue < ActiveRecord::Base
  has_many :article_issues
  outpost_model
  has_secretary
  attr_accessible :description, :is_active, :slug, :title
  include Concern::Validations::SlugValidation

  ROUTE_KEY = 'root_slug'

  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end

end

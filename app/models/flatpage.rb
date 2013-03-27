class Flatpage < ActiveRecord::Base
  self.table_name = "flatpages_flatpage"
  outpost_model
  has_secretary
  
  include Concern::Callbacks::SphinxIndexCallback

  TEMPLATE_OPTIONS = [
    ["Normal (with sidebar)",   "inherit"],
    ["Full Width (no sidebar)", "full"],
    ["Crawford Family Forum",   "forum"],
    ["No Template",             "none"]
  ]
  
  # -------------------
  # Scopes
  scope :visible, -> { where(is_public: true) }

  # -------------------
  # Associations
  
  # -------------------
  # Validations
  validates :url, presence: true, uniqueness: true
  
  # -------------------
  # Callbacks
  before_validation :slashify
  def slashify
    if url.present? and path.present?
      self.url = "/#{path}/"
    end
  end
  
  # Downcase URL so uniqueness validation works.
  before_validation :downcase_url
  def downcase_url
    if url.present? 
      self.url = url.downcase
    end
  end

  # -------------------
  # Sphinx  
  define_index do
    indexes url, sortable: true
    indexes title
    indexes description
    indexes redirect_url
    has updated_at
  end
  
  # -------------------

  def path
    url.gsub(/\A\//, "").gsub(/\/\z/, "")
  end
  
  # -------------------
  
  # Just to be safe while the URLs are still being created in mercer
  def url
    if self[:url].present?
      if self[:url] !~ /\A\//
        "/#{self[:url]}"
      else
        self[:url]
      end
    end
  end

  # -------------------
  # Override Outpost for this
  def link_path(options={})
    self.url
  end

  # -------------------

  def is_redirect?
    self.redirect_url.present?
  end
end

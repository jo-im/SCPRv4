class Vertical < ActiveRecord::Base
  outpost_model
  has_secretary except: ["quote_id"] # Quote is versioned separately

  include Concern::Validations::SlugValidation
  include Concern::Model::Searchable
  include Concern::Associations::TagsAssociation

  self.public_route_key = 'root_slug'

  FEATURED_INTERACTIVE_STYLES = {
    0 => 'beams',
    1 => 'traffic',
    2 => 'palmtrees',
    3 => 'map'
  }

  belongs_to :quote
  accepts_nested_attributes_for :quote,
    :reject_if => :should_reject_quote,
    :allow_destroy => true
  tracks_association :quote

  belongs_to :category
  belongs_to :blog

  has_many :vertical_reporters, dependent: :destroy
  has_many :reporters,
    :through => :vertical_reporters,
    :source  => :bio
  tracks_association :reporters

  has_many :vertical_articles,
    -> { order('position') },
    :class_name => "VerticalArticle",
    :dependent  => :destroy

  accepts_json_input_for :vertical_articles
  tracks_association :vertical_articles


  validates :title, :slug, :category_id, presence: true


  class << self
    def interactive_select_collection
      FEATURED_INTERACTIVE_STYLES.map { |k,v| [v.titleize, k] }
    end
  end

  # This category's hand-picked content,
  # converted to articles.
  def featured_articles
    @featured_articles ||= self.vertical_articles
      .includes(:article).select(&:article)
      .map { |a| a.article }
  end


  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end


  def featured_interactive_style
    FEATURED_INTERACTIVE_STYLES[self.featured_interactive_style_id]
  end


  private

  def should_reject_quote(attributes)
    attributes["source_name"].blank? &&
    attributes["source_context"].blank? &&
    attributes["source_text"].blank?
  end

  def build_vertical_article_association(vertical_article_hash, article)
    if article.published?
      VerticalArticle.new(
        :position   => vertical_article_hash["position"].to_i,
        :article    => article,
        :vertical   => self
      )
    end
  end
end

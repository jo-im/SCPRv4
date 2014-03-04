class Vertical < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Validations::SlugValidation
  include Concern::Callbacks::SphinxIndexCallback

  ROUTE_KEY = 'root_slug'

  FEATURED_INTERACTIVE_STYLES = {
    0 => 'beams',
    1 => 'traffic',
    2 => 'palmtrees',
    3 => 'map'
  }

  has_many :events
  has_many :quotes,
    :order => "created_at desc"

  has_many :vertical_issues, dependent: :destroy
  has_many :issues, through: :vertical_issues
  tracks_association :issues

  has_many :vertical_reporters, dependent: :destroy
  has_many :reporters, through: :vertical_reporters
  tracks_association :reporters

  has_many :vertical_articles,
    :order        => 'position',
    :dependent    => :destroy

  accepts_json_input_for :vertical_articles
  tracks_association :vertical_articles


  # This category's hand-picked content,
  # converted to articles.
  def featured_articles
    @featured_articles ||= self.vertical_articles
      .includes(:article).select(&:article)
      .map { |a| a.article.to_article }
  end


  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end


  def featured_interactive_style
    FEATURED_INTERACTIVE_STYLES[self.featured_interactive_style_id]
  end


  private

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

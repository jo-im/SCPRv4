class Category < ActiveRecord::Base
  self.table_name = 'contentbase_category'
  outpost_model
  has_secretary

  include Concern::Validations::SlugValidation
  include Concern::Callbacks::SphinxIndexCallback

  ROUTE_KEY = 'root_slug'

  DEFAULTS = {
    :page       => 1,
    :per_page   => 10,
    :classes    => [NewsStory, ContentShell, BlogEntry, ShowSegment]
  }


  FEATURED_INTERACTIVE_STYLES = {
    0 => 'beams',
    1 => 'traffic',
    2 => 'palmtrees',
    3 => 'map'
  }

  belongs_to :featured_blog, class_name: 'Blog', foreign_key: 'blog_id'
  has_many :category_articles, order: 'position', dependent: :destroy
  accepts_json_input_for :category_articles
  tracks_association :category_articles

  has_many :category_reporters, dependent: :destroy
  has_many :bios, through: :category_reporters
  tracks_association :bios

  has_many :category_issues, dependent: :destroy
  has_many :issues, through: :category_issues
  tracks_association :issues

  belongs_to :comment_bucket, class_name: "FeaturedCommentBucket"

  has_many :events
  has_many :quotes,
    :foreign_key    => "category_id",
    :order          => "created_at desc"



  validates :title, presence: true


  class << self
    # Get all Category previews which have articles,
    # ordered reverse-chronologically by first
    # article timestamp.
    def previews(options={})
      categories = options.delete(:categories) || self.all

      previews = []

      categories.each do |category|
        previews << category.preview(options)
      end

      previews.reject { |p| p.articles.empty? }
      .sort_by { |p| -p.articles.first.public_datetime.to_i }
    end
  end


  # This category's hand-picked content,
  # converted to articles.
  def featured_articles
    @featured_articles ||= self.category_articles
      .includes(:article).select(&:article)
      .map { |a| a.article.to_article }
  end


  # This category's content converted to Articles.
  def articles(options={})
    content(options).map(&:to_article)
  end


  # All content associated to this category.
  def content(options={})
    classes   = options[:classes] || DEFAULTS[:classes]
    page      = options[:page] || DEFAULTS[:page]
    per_page  = options[:per_page] || DEFAULTS[:per_page]
    exclude   = options[:exclude]
    with      = options[:with] || {}

    if (page.to_i * per_page.to_i > SPHINX_MAX_MATCHES) || page.to_i < 1
      page = 1
    end

    args = {
      :classes    => classes,
      :page       => page,
      :per_page   => per_page,
      :with       => { category: self.id }.merge(with)
    }

    if exclude.present?
      if exclude.kind_of?(Array)
        excluded_articles = exclude.select do |article|
          article.respond_to?(:obj_key_crc32)
        end

        args[:without] = { obj_key: excluded_articles.map(&:obj_key_crc32) }
      elsif exclude.respond_to?(:obj_key_crc32)
        args[:without] = { obj_key: exclude.obj_key_crc32 }
      end
    end
    ContentBase.search(args)
  end


  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end


  # The Preview for this category.
  def preview(options={})
    @preview ||= CategoryPreview.new(self, options)
  end

  def featured_interactive_style
    FEATURED_INTERACTIVE_STYLES[self.featured_interactive_style_id]
  end


  private

  def build_category_article_association(category_article_hash, article)
    if article.published?
      CategoryArticle.new(
        :position   => category_article_hash["position"].to_i,
        :article    => article,
        :category   => self
      )
    end
  end
end

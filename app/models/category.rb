class Category < ActiveRecord::Base
  self.table_name = 'contentbase_category'
  outpost_model
  has_secretary

  include Concern::Validations::SlugValidation
  include Concern::Callbacks::SphinxIndexCallback

  self.public_route_key = 'root_slug'

  DEFAULTS = {
    :page       => 1,
    :per_page   => 10,
    :classes    => [NewsStory, ContentShell, BlogEntry, ShowSegment]
  }


  has_many :events
  belongs_to :comment_bucket, class_name: "FeaturedCommentBucket"

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
      exclude = Array(exclude).select do |article|
        article.respond_to?(:obj_key_crc32)
      end

      args[:without] = { obj_key: exclude.map(&:obj_key_crc32) }
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
end

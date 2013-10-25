class Category < ActiveRecord::Base
  self.table_name = 'contentbase_category'
  outpost_model
  has_secretary

  include Concern::Validations::SlugValidation
  include Concern::Callbacks::SphinxIndexCallback

  ROUTE_KEY = 'root_slug'

  DEFAULTS = {
    :page       => 1,
    :per_page   => 10
  }

  #-------------------
  # Scopes

  #-------------------
  # Associations
  belongs_to :comment_bucket, class_name: "FeaturedCommentBucket"

  #-------------------
  # Validations
  validates :title, presence: true

  #-------------------
  # Callbacks

  #----------

  class << self
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


  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end

  #----------

  def content(options={})
    page      = options[:page] || DEFAULTS[:page]
    per_page  = options[:per_page] || DEFAULTS[:per_page]
    exclude   = options[:exclude]

    if (page.to_i * per_page.to_i > SPHINX_MAX_MATCHES) || page.to_i < 1
      page = 1
    end

    args = {
      :classes  => [NewsStory, ContentShell, BlogEntry, ShowSegment],
      :page     => page,
      :per_page => per_page,
      :with     => { category: self.id }
    }

    if exclude && exclude.respond_to?(:obj_key_crc32)
      args[:without] = { obj_key: exclude.obj_key_crc32 }
    end

    ContentBase.search(args)
  end


  def preview(options={})
    @preview ||= CategoryPreview.new(self, options)
  end
end

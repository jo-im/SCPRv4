class Category < ActiveRecord::Base
  self.table_name = 'contentbase_category'
  outpost_model
  has_secretary

  include Concern::Validations::SlugValidation
  include Concern::Callbacks::SphinxIndexCallback

  ROUTE_KEY = 'root_slug'

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
      previews = []

      self.all.each do |category|
        previews << category.preview(options)
      end

      previews
    end
  end


  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end

  #----------

  def content(page=1, per_page=10, without_obj=nil)
    if (page.to_i * per_page.to_i > SPHINX_MAX_MATCHES) || page.to_i < 1
      page = 1
    end

    args = {
      :classes  => [NewsStory, ContentShell, BlogEntry, ShowSegment],
      :page     => page,
      :per_page => per_page,
      :with     => { category: self.id }
    }

    if without_obj && without_obj.respond_to?(:obj_key)
      args[:without] = { obj_key: without_obj.obj_key }
    end

    ContentBase.search(args)
  end


  def preview(options={})
    @preview ||= CategoryPreview.new(self, options)
  end
end

class Podcast < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Model::Searchable
  include Concern::Sanitizers::Url

  self.public_route_key = "podcast"

  ITEM_TYPES = [
    ["Episodes", 'episodes'],
    ["Segments", 'segments'],
    ["Content", 'content']
  ]

  SOURCES = ["KpccProgram", "ExternalProgram", "Blog"]

  CONTENT_CLASSES = [
    NewsStory,
    ShowSegment,
    BlogEntry
  ]



  belongs_to :source, polymorphic: true
  belongs_to :category


  validates :slug, uniqueness: true, presence: true
  validates :title, presence: true

  validates :url, presence: true, url: true
  validates :podcast_url, presence: true, url: true
  validates :itunes_url, url: { allow_blank: true }
  validates :image_url, url: { allow_blank: true }

  before_save ->{ sanitize_urls :url, :podcast_url, :itunes_url, :image_url }



  def content(limit=25)
    @content ||= begin
      klasses    = []
      conditions = {}
      conditions[:with] = {};
      conditions[:without] = {};

      case self.source_type
      when "KpccProgram"
        conditions[:with].merge!("show.id" => self.source.id)
        klasses.push ShowEpisode if self.item_type == "episodes"
        klasses.push ShowSegment if self.item_type == "segments"

      when "ExternalProgram"
        # ExternalProgram won't actually have any content
        # So, just incase this method gets called,
        # just return an empty array.
        return []

      when "Blog"
        conditions[:with].merge!("blog.id" => self.source.id)
        klasses.push BlogEntry

      else
        if item_type == "content"
          # Exclude NPR articles from our ES query result
          # by providing a byline regex that looks for "| NPR" at the end
          conditions[:without].merge!("byline" => /NPR/)
          klasses = [NewsStory, BlogEntry, ShowSegment]
        end
      end

      results = content_query(limit, klasses, conditions)
      results.map(&:to_article)
    end
  end


  def itunes_category
    ITUNES_CATEGORIES[self.itunes_category_id]
  end


  def route_hash
    return {} if !self.persisted?
    { slug: self.slug }
  end

  ## This is to provide the correct context parameter
  ## for a podcast item URL since some of the podcast
  ## slugs don't match their programs, making things 
  ## difficult for analytics.  It first relies on the 
  ## source slug and falls back on the slug attribute.
  def context
    if source = self.source
      source.slug || self.slug
    else
      self.slug
    end
  end


  private

  def content_query(limit, klasses, conditions={})
    ContentBase.search({
      :with    => conditions[:with].reverse_merge({
        "audio.url" => true
      }),
      :without => conditions[:without],
      :classes => klasses,
      :limit   => limit
    })
  end
end

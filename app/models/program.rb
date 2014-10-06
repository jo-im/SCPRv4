# Public API for Programs
#
# When you pass in episodes, it has to be either an Array or a Relation
# This is to prevent accidental loading of hundreds of episodes.
class Program
  include Concern::Methods::AbstractModelMethods

  class << self
    def all
      (KpccProgram.all + ExternalProgram.all).map(&:to_program)
    end

    def find_by_slug(slug)
      program = KpccProgram.find_by_slug(slug) ||
      ExternalProgram.find_by_slug(slug)

      program.try(:to_program)
    end

    def find_by_slug!(slug)
      find_by_slug(slug) or raise ActiveRecord::RecordNotFound
    end

    def where(conditions)
      (KpccProgram.where(conditions) + ExternalProgram.where(conditions))
      .map(&:to_program)
    end
  end


  attr_accessor \
    :original_object,
    :id,
    :source,
    :title,
    :slug,
    :description,
    :host,
    :air_status,
    :airtime,
    :podcast_url,
    :rss_url,
    :episodes,
    :segments,
    :blog,
    :is_featured,
    :is_segmented

  alias_method :is_featured?, :is_featured
  alias_method :is_segmented?, :is_segmented


  def initialize(attributes={})
    @original_object  = attributes[:original_object]
    @id               = attributes[:id]
    @source           = attributes[:source]
    @title            = attributes[:title]
    @slug             = attributes[:slug]
    @description      = attributes[:description]
    @host             = attributes[:host]
    @air_status       = attributes[:air_status]
    @airtime          = attributes[:airtime]
    @podcast_url      = attributes[:podcast_url]
    @rss_url          = attributes[:rss_url]
    @blog             = attributes[:blog]

    # Force to boolean
    @is_featured  = !!attributes[:is_featured]
    @is_segmented  = !!attributes[:is_segmented]

    # Don't force these into an array, so it doesn't load ALL
    # of the episodes/segments (which could be thousands).
    @episodes   = attributes[:episodes]
    @segments   = attributes[:segments]
  end

  def to_program
    self
  end

  # Delegate get_link to original object,
  # just so we don't have to redefine it.
  def get_link(type)
    if self.original_object
      self.original_object.get_link(type)
    end
  end
end

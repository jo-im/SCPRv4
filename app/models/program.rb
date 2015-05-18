# Public API for Programs
#
# When you pass in episodes, it has to be either an Array or a Relation
# This is to prevent accidental loading of hundreds of episodes.
class Program
  include Concern::Methods::AbstractModelMethods

  class << self
    def all
      (KpccProgram.all + ExternalProgram.all)
    end

    def find_by_slug(slug)
      program = KpccProgram.find_by_slug(slug) ||
      ExternalProgram.find_by_slug(slug)

      program
    end

    def find_by_slug!(slug)
      find_by_slug(slug) or raise ActiveRecord::RecordNotFound
    end

    def where(conditions)
      (KpccProgram.includes(:related_links).where(conditions) + ExternalProgram.includes(:related_links).where(conditions))
    end
  end
end

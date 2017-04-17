# Public API for Programs
#
# When you pass in episodes, it has to be either an Array or a Relation
# This is to prevent accidental loading of hundreds of episodes.
class Program
  include Concern::Methods::AbstractModelMethods

  attr_accessor :title, 
                :description, 
                :host,
                :admin_edit_path,
                :public_path,
                :created_at,
                :updated_at,
                :obj_key,
                :original_object

      :id                 => self.obj_key,
      :title              => self.title,
      :short_title        => self.title,
      :public_datetime    => self.created_at,
      :teaser             => self.description,
      :body               => self.description,
      :assets             => [],
      :attributions       => [ContentByline.new(name: self.host)],
      :byline             => self.host,
      :edit_path          => self.admin_edit_path,
      :public_path        => self.public_path,
      :tags               => [],
      :feature            => [],
      :created_at         => self.created_at,
      :updated_at         => self.updated_at,
      :published          => true,
      :related_content    => [],
      :links              => [],
      :asset_display      => "photo"

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

class ExternalSegment < ActiveRecord::Base
  include Outpost::Model::Identifier
  include Concern::Associations::AudioAssociation
  include Concern::Sanitizers::Url

  belongs_to :external_program

  has_many :external_episode_segments, dependent: :destroy

  has_many :external_episodes,
    :through   => :external_episode_segments

  validates :external_url, url: { allow_blank: true }

  scope :published, -> {}

  before_save ->{ sanitize_urls :external_url }

  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.title,
      :short_title        => self.title,
      :public_datetime    => self.published_at,
      :teaser             => self.teaser,
      :body               => self.teaser,
      :audio              => self.audio.available,
      :byline             => self.external_program.organization,
      :created_at         => self.created_at,
      :updated_at         => self.updated_at,
      :published          => true,
      :public_path        => self.external_url,
    })
  end

  def public_url
    self.external_url
  end

  # Temporary work-around
  def show
    self.external_program
  end
end

class KpccProgram < ActiveRecord::Base
  self.table_name = 'programs_kpccprogram'
  outpost_model
  has_secretary except: ["quote_id"] # Quote is versioned separately

  include Concern::Validations::SlugValidation
  include Concern::Associations::RelatedLinksAssociation
  include Concern::Associations::PodcastAssociation
  include Concern::Model::Searchable
  include Concern::Model::Programs

  self.public_route_key = "program"

  PROGRAM_STATUS = {
    "onair"      => "Currently Airing",
    "online"     => "Online",
    "hidden"     => "Not Listed"
  }

  AIR_STATUS = PROGRAM_STATUS.invert

  #-------------------
  # Scopes
  scope :active, -> { where(air_status: ['onair','online']) }

  scope :can_sync_audio, -> {
    where(air_status: "onair")
    .where("audio_dir is not null")
    .where("audio_dir != ?", "")
  }


  #-------------------
  # Associations
  has_many :segments, foreign_key: "show_id", class_name: "ShowSegment", dependent: :destroy
  has_many :episodes, foreign_key: "show_id", class_name: "ShowEpisode", dependent: :destroy
  has_many :recurring_schedule_rules, as: :program, dependent: :destroy
  has_many :tags, as: :parent

  belongs_to :blog
  belongs_to :quote
  accepts_nested_attributes_for :quote,
    :reject_if => :should_reject_quote,
    :allow_destroy => true
  tracks_association :quote

  has_many :program_reporters,
    :foreign_key => "program_id",
    :dependent => :destroy
  has_many :reporters,
    :through => :program_reporters,
    :source  => :bio
  tracks_association :reporters

  has_many :program_articles,
    -> { order('position') },
    :foreign_key => "program_id",
    :dependent  => :destroy

  accepts_json_input_for :program_articles
  tracks_association :program_articles

  #-------------------
  # Validations
  validates :title, :air_status, presence: true
  validates :slug, presence: true, uniqueness: true
  validate :slug_is_unique_in_programs_namespace


  #-------------------
  # Callbacks

  #-------------------

  class << self
    def select_collection
      KpccProgram.order("field(air_status, 'onair', '') desc, title")
      .map { |p| [p.to_title, p.id] }
    end
  end

  def published?
    self.air_status != "hidden"
  end

  #----------

  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :show           => self.persisted_record.slug,
      :trailing_slash => true
    }
  end

  def podcast_url
    self.get_link('podcast')
  end

  def rss_url
    self.get_link('rss')
  end

  def featured_articles
    @featured_articles ||= self.program_articles
      .includes(:article).select(&:article)
      .map { |a| a.article.to_article }
  end

  def is_kpcc
    true
  end

  def safe_newsletter_form_caption
    safe_title = ->(title){
      if (title || "").match(/^The\s/)
        title
      else
        "the #{title}"
      end
    }
    if newsletter_form_caption && !newsletter_form_caption.empty?
      newsletter_form_caption
    else
      "Catch up with #{safe_title.call(title)} newsletter."
    end
  end

  def safe_newsletter_form_heading
    if newsletter_form_heading && !newsletter_form_heading.empty?
      newsletter_form_heading
    else
      "Like #{title}?"
    end
  end

  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
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
    })
  end

  def obj_key
    if id
      "kpcc_program-#{id}"
    end
  end

  private

  def should_reject_quote(attributes)
    attributes["source_name"].blank? &&
    attributes["source_context"].blank? &&
    attributes["source_text"].blank?
  end

  def slug_is_unique_in_programs_namespace
    if self.slug.present? && ExternalProgram.exists?(slug: self.slug)
      self.errors.add(:slug, "must be unique between both " \
                             "KpccProgram and ExternalProgram")
    end
  end

  def build_program_article_association(program_article_hash, article)
    if article.published?
      ProgramArticle.new(
        :position   => program_article_hash["position"].to_i,
        :article    => article,
        :kpcc_program   => self
      )
    end
  end
end

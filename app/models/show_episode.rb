class ShowEpisode < ActiveRecord::Base
  self.table_name = "shows_episode"
  outpost_model
  has_secretary
  has_status

  include Concern::Scopes::SinceScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Associations::AudioAssociation
  include Concern::Associations::AssetAssociation
  include Concern::Associations::RelatedContentAssociation
  include Concern::Associations::RelatedLinksAssociation
  include Concern::Associations::BylinesAssociation
  include Concern::Associations::EditionsAssociation
  include Concern::Associations::FeatureAssociation
  include Concern::Associations::PmpContentAssociation::StoryProfile
  include Concern::Associations::EpisodeRundownAssociation
  include Concern::Callbacks::GenerateShortHeadlineCallback
  include Concern::Callbacks::SetPublishedAtCallback
  #include Concern::Callbacks::CacheExpirationCallback
  include Concern::Callbacks::PublishNotificationCallback
  include Concern::Model::Searchable
  include Concern::Callbacks::TouchCallback
  include Concern::Methods::CommentMethods
  include Concern::Methods::AssetDisplayMethods

  alias_attribute :title, :headline
  alias_attribute :public_datetime, :published_at

  attr_accessor :pre_count, :post_count, :insertion_points, :podcast_episode_request_body

  self.public_route_key = "episode"

  scope :with_article_includes, ->() { includes(:assets,:audio,:show) }

  status :killed do |s|
    s.id = -1
    s.text = "Killed"
    s.unpublished!
  end

  status :draft do |s|
    s.id = 0
    s.text = "Draft"
    s.unpublished!
  end

  status :pending do |s|
    s.id = 3
    s.text = "Pending"
    s.pending!
  end

  status :live do |s|
    s.id = 5
    s.text = "Published"
    s.published!
  end


  scope :published, -> {
    where(status: self.status_id(:live))
    .order("air_date desc, published_at desc")
  }

  scope :upcoming, -> {
    where(status: self.status_id(:pending))
    .where("air_date >= ?", Date.today)
    .order("air_date asc")
  }

  scope :for_air_date, ->(date_or_time) {
    where("DATE(air_date) = DATE(?)", date_or_time)
  }

  belongs_to :show,
    :class_name  => "KpccProgram",
    :touch       => true

  has_many :rundowns,
    class_name:   "ShowRundown",
    foreign_key:  "episode_id",
    inverse_of:   :episode,
    dependent:    :destroy,
    before_add:   :set_rundown_position

  has_one :broadcast_content, as: :content

  ## Rundown type relations

  [:show_segments,:news_stories,:content_shells,:blogs,:show_episodes,:abstracts,:events,:pij_queries].each do |content_type|
    model_name = content_type.to_s.singularize.camelize
    has_many content_type,
      -> { where('shows_rundown.content_type' => model_name).order('shows_rundown.position') },
      :through        => :rundowns,
      :source         => :content,
      :source_type    => model_name
  end

  alias_attribute :segments, :show_segments


  accepts_json_input_for :rundowns
  tracks_association :rundowns


  validates :show, presence: true
  validates :status, presence: true
  validates :teaser, presence: true, if: :should_validate?
  validates :air_date, presence: true, if: :should_validate?

  before_save :generate_headline,
    :if => -> { self.headline.blank? }

  before_save :generate_body, if: -> { self.body.blank? && should_validate? }

  after_create :create_podcast_episode

  after_destroy :delete_podcast_episode

  after_update :update_podcast_episode

  def podcast_episode_request_body
    @podcast_episode_request_body ||= {}
  end

  def podcast_episode_record
    @podcast_episode_record ||=
      begin
        $megaphone.episodes.search({ externalId: "#{self.obj_key}__#{Rails.env}" }).first
      rescue
        {}
      end
  end

  def insertion_points
    @insertion_points ||= podcast_episode_record.try(:[], 'insertionPoints').try(:join, ", ")
  end

  def insertion_points=(new_insertion_points)
    if new_insertion_points != insertion_points
      @insertion_points = new_insertion_points
      @podcast_episode_request_body = podcast_episode_request_body.merge({ insertionPoints: @insertion_points })
    end
  end

  def post_count
    @post_count ||= podcast_episode_record.try(:[], 'postCount')
  end

  def post_count=(new_count)
    if new_count.to_i != post_count
      @post_count = new_count.to_i
      @podcast_episode_request_body = podcast_episode_request_body.merge({ postCount: @post_count })
    end
  end

  def pre_count
    @pre_count ||= podcast_episode_record.try(:[], 'preCount')
  end

  def pre_count=(new_count)
    if new_count.to_i != pre_count
      @pre_count = new_count.to_i
      @podcast_episode_request_body = podcast_episode_request_body.merge({ pre_count: @pre_count })
    end
  end

  def short_headline
    super || self.headline
  end

  def needs_validation?
    self.pending? || self.published?
  end

  def publish
    self.update_attributes(status: self.class.status_id(:live))
  end

  def content
    rundowns.includes(:content).map(&:content)
  end

  def published_content
    content.select(&:published?)
  end

  def to_article
    return nil if !self.show
    related_content = to_article_called_more_than_twice? ? [] : self.published_content.map(&:get_article).map(&:to_reference)
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.headline,
      :short_title        => self.headline,
      :public_datetime    => self.air_date,
      :body               => self.body,
      :teaser             => self.teaser,
      :assets             => self.assets,
      :audio              => self.audio.select(&:available?),
      :byline             => self.show.title,
      :edit_path          => self.admin_edit_path,
      :public_path        => self.public_path,
      :created_at         => self.created_at,
      :updated_at         => self.updated_at,
      :published          => self.published?,
      :show               => self.show,
      :related_content    => related_content,
      :links              => related_links.map(&:to_hash),
      :asset_display      => asset_display,
      :disqus_identifier  => self.disqus_identifier,
      :abstract           => self.abstract
    })
  end

  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :show           => self.persisted_record.show.slug,
      :year           => self.persisted_record.air_date.year.to_s,
      :month          => "%02d" % self.persisted_record.air_date.month,
      :day            => "%02d" % self.persisted_record.air_date.day,
      :id             => self.id.to_s,
      :trailing_slash => true
    }
  end

  def to_episode
    @to_episode ||= Episode.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.headline,
      :summary            => self.teaser,
      :air_date           => self.air_date,
      :assets             => self.assets,
      :audio              => self.audio.available,
      :program            => self.show,
      :segments           => self.segments.published.map(&:get_article),
      :content            => self.published_content.map(&:get_article)
    })
  end

  private

  def generate_headline
    if self.air_date.present? && self.show.present?
      self.headline = "#{self.show.title} for " \
        "#{self.air_date.strftime("%B %-d, %Y")}"
    end
  end

  def generate_body
    self.body = self.teaser
  end

  def build_rundown_association(rundown_hash, segment)
    ShowRundown.new(
      :position => rundown_hash["position"].to_i,
      :content => segment
    )
  end

  def not_from_media_server(available_audio)
    available_audio.try(:length) > 0 && !available_audio.try(:first).try(:url).include?('media.scpr.org')
  end

  def create_podcast_episode
    podcast_id = self.try(:show).try(:podcast).try(:external_podcast_id)
    draft = self.status == 5 ? false : true
    body = {
      author: self.show.title,
      draft: draft,
      externalId: "#{self.obj_key}__#{Rails.env}",
      pubdateTimezone: Time.zone.name,
      pubdate: self.air_date || Time.zone.now + 1.year,
      summary: self.teaser,
      title: self.headline
    }

    available_audio = self.audio.select(&:available?)

    if not_from_media_server(available_audio)
      body = body.merge({
        backgroundAudioFileUrl: available_audio.first.url
      })
    end

    if podcast_id.present? && @podcast_episode_record.nil?
      begin
        $megaphone
          .podcast(podcast_id)
          .episode
          .create(body)
      rescue
        {}
      end
    end
  end

  def delete_podcast_episode
    podcast_id = self.try(:show).try(:podcast).try(:external_podcast_id)

    if podcast_id.present? && podcast_episode_record.present?
      episode_id = podcast_episode_record['id']
      begin
        $megaphone
          .podcast(podcast_id)
          .episode(episode_id)
          .delete
      rescue
        {}
      end
    end
  end

  def update_podcast_episode
    podcast_id = self.try(:show).try(:podcast).try(:external_podcast_id)

    # If a podcast episode doesn't exist on Megaphone's side, try to create it
    if podcast_id && @podcast_episode_record.nil?
      return create_podcast_episode
    end

    property_mapper = {
      air_date: "pubdate",
      audio: "backgroundAudioFileUrl",
      status: "draft",
      headline: "title",
      teaser: "summary"
    }

    changes = {};

    self.changes.each do |attribute, change|
      attribute_symbol = attribute.to_sym
      if property_mapper[attribute_symbol].present?
        key = property_mapper[attribute_symbol]
        value = change[1]

        if attribute_symbol == :audio
          value = change[1].try(:first).try(:url)
        end

        if attribute_symbol == :status
          change[1] == 5 ? value = false : value = true
        end

        changes[key] = value
      end
    end

    if podcast_episode_record.present?
      # If the audio file is null from the podcast record
      available_audio = self.audio.select(&:available?)
      if podcast_episode_record['audioFile'].nil? && not_from_media_server(available_audio)
        changes["backgroundAudioFileUrl"] = available_audio.first.url
      end
    end

    @podcast_episode_request_body = (@podcast_episode_request_body || {}).merge(changes)
    if @podcast_episode_request_body.present? && podcast_episode_record.present?
      podcast_id = podcast_episode_record['podcastId']
      episode_id = podcast_episode_record['id']
      begin
        $megaphone
          .podcast(podcast_id)
          .episode(episode_id)
          .update(@podcast_episode_request_body)
      rescue
        {}
      end
    end
  end
end






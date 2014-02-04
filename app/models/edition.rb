# A collection of items, which are meant to be represented
# as Abstracts (although not all of them will actually be
# an Abstract object).
#
# This model was created originally for the mobile application,
# but there's no reason it couldn't also be presented on the
# website if there was a place out for it.
class Edition < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status

  include Concern::Associations::ContentAlarmAssociation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Scopes::PublishedScope
  include Concern::Methods::StatusMethods


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
    s.text = "Live"
    s.published!
  end


  has_many :slots,
    :class_name   => "EditionSlot",
    :order        => "position",
    :dependent    => :destroy

  accepts_json_input_for :slots


  validates :status, presence: true
  validates :title,
    :presence   => true,
    :if         => :should_validate?

  after_save :async_send_email, if: :should_send_email?

  class << self
    def titles_collection
      self.where(status: self.status_id(:live))
      .select('distinct title').order('title').map(&:title)
    end

    def eloqua_config
      @eloqua_config ||= Rails.application.config.api['eloqua']['attributes']
    end
 end


  def needs_validation?
    self.pending? || self.published?
  end


  # Returns an array of Abstract objects
  # by mapping all of the items to Abstract objects.
  def abstracts
    @abstracts ||= self.slots.includes(:item).map { |slot|
      slot.item.to_abstract
    }
  end

  def articles
    @articles ||= self.slots.includes(:item).map { |slot|
      slot.item.to_article
    }
  end


  def publish
    self.update_attributes(status: self.class.status_id(:live))
  end

  def async_send_email
    Resque.enqueue(Job::SendShortListEmail, self.id)
  end

  #-------------------
  # Send the e-mail
  def publish_email
    return false if !should_send_email?

    email = Eloqua::Email.create(
      :folderId         => self.class.eloqua_config['email_folder_id'],
      :emailGroupId     => self.class.eloqua_config['email_group_id'],
      :senderName       => "89.3 KPCC",
      :senderEmail      => "no-reply@kpcc.org",
      :replyToName      => "89.3 KPCC",
      :replyToEmail     => "no-reply@kpcc.org",
      :isTracked        => true,
      :name             => email_name,
      :description      => email_description,
      :subject          => email_subject,
      :isPlainTextEditable => true,
      :plainText        => email_plain_text_body,
      :htmlContent      => {
        :type => "RawHtmlContent",
        :html => email_html_body
      }
    )

    campaign = Eloqua::Campaign.create(
      {
        :folderId         => self.class.eloqua_config['campaign_folder_id'],
        :name             => email_name,
        :description      => email_description,
        :startAt          => Time.now.yesterday.to_i,
        :endAt            => Time.now.tomorrow.to_i,
        :elements         => [
          {
            :type           => "CampaignSegment",
            :id             => "-980",
            :name           => "Segment Members",
            :segmentId      => self.class.eloqua_config['segment_id'],
            :position       => {
              :type => "Position",
              :x    => 17,
              :y    => 14
            },
            :outputTerminals => [
              {
                :type          => "CampaignOutputTerminal",
                :id            => "-981",
                :connectedId   => "-990",
                :connectedType => "CampaignEmail",
                :terminalType  => "out"
              }
            ]
          },
          {
            :type             => "CampaignEmail",
            :id               => "-990",
            :emailId          => email.id,
            :sendTimePeriod   => "sendAllEmailAtOnce",
            :position       => {
              :type => "Position",
              :x    => 17,
              :y    => 120
            },
          }
        ]
      }
    )

    if campaign
      self.update_column(:email_sent, true)
    end
  end

  #what is this??
#  add_transaction_tracer :publish_email, category: :task

  #-------------------

  def email_html_body
    @email_html_body ||= view.render_view(
      :template   => "/editions/email/template",
      :formats    => [:html],
      :locals     => { edition: self }
    ).to_s
  end

  def email_plain_text_body
    @email_plain_text_body ||= view.render_view(
      :template   => "/editions/email/template",
      :formats    => [:text],
      :locals     => { edition: self }
    ).to_s
  end

  def email_name
    @email_name ||= "#{self.title}"
  end

  def email_description
    @email_description ||= "SCPR Short List\n" \
      "Sent: #{Time.now}\nSubject: #{email_subject}"
  end

  def email_subject
    @email_subject ||= "#{self.title}: #{self.abstracts.first.headline}"
  end

  private

  def view
    @view ||= CacheController.new
  end

  def should_send_email?
    self.published? && !self.email_sent?
  end

  def build_slot_association(slot_hash, item)
    if item.published?
      EditionSlot.new(
        :position   => slot_hash["position"].to_i,
        :item       => item,
        :edition    => self
      )
    end
  end
end

# A collection of items, which are meant to be represented
# as Abstracts (although not all of them will actually be an Abstract object).
#
# This model was created originally for the mobile application,
# but there's no reason it couldn't also be presented on the
# website if there was a place out for it.
class Edition < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status
  has_many :eloqua_emails, as: :emailable

  include Concern::Associations::ContentAlarmAssociation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Model::Searchable
  include Concern::Scopes::PublishedScope
  include Concern::Associations::BylinesAssociation


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

  SHORT_LIST_TYPES = {
    'am-edition'      => 'A.M. Edition',
    'pm-edition'      => 'P.M. Edition',
    'weekend-reads'   => 'Weekend Reads'
  }

  scope :recently, ->{ where("published_at > ?", 3.hours.ago) }

  has_many :slots,
    -> { order('position') },
    :class_name   => "EditionSlot",
    :dependent    => :destroy

  accepts_json_input_for :slots


  validates :status, presence: true
  validates :title,
    :presence   => true,
    :if         => :should_validate?

  after_save :send_shortlist_email, if: :should_send_shortlist_email?
  after_save :send_monday_email, if: :should_send_monday_email?

  class << self
    def titles_collection
      self.where(status: self.status_id(:live))
      .select('distinct title').order('title').map(&:title)
    end

    def slug_select_collection
      SHORT_LIST_TYPES.map { |k,v| [v.titleize, k] }
    end
  end

  self.public_route_key = "short_list"

  def short_list_type
    SHORT_LIST_TYPES[self.slug]
  end

  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :year           => self.persisted_record.published_at.year.to_s,
      :month          => "%02d" % self.persisted_record.published_at.month,
      :day            => "%02d" % self.persisted_record.published_at.day,
      :id             => self.persisted_record.id.to_s,
      :slug           => self.persisted_record.slug,
      :trailing_slash => true
    }
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

  def sister_editions
    self.class.published.where.not(id: self.id).first(4)
  end

  def html_body
    subject = "The Short List: #{self.title}"
    EloquaEmail.new({
      :emailable     => self,
      :html_template   => "/editions/email/template",
      :plain_text_template   => "/editions/email/template",
      :name        => "[tsl #{Time.zone.now.strftime("%Y%m%d")}] #{self.title[0..30]}",
      :description => "SCPR Short List\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{subject}",
      :subject     => subject,
      :email       => "theshortlist@scpr.org",
      :email_type  => "shortlist"
    }).html_body
  end

  def monday_html_body
    # NOTE: This is ugly as hell but will only be around for the short term.
    # Please, PLEASE remove this ASAP.

    subject = "The Short List: #{self.title}"
    EloquaEmail.new({
      :emailable     => self,
      :html_template   => "/editions/email/monday/template",
      :plain_text_template   => "/editions/email/monday/template",
      :name        => "[tslm #{Time.zone.now.strftime("%Y%m%d")}] #{self.title[0..30]}",
      :description => "SCPR Monday Short List\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{subject}",
      :subject     => subject,
      :email       => "theshortlist@scpr.org",
      :email_type  => "monday_shortlist"
    }).html_body
  end


  def text_body
    # NOTE: This is ugly as hell but will only be around for the short term.
    # Please, PLEASE remove this ASAP.

    subject = "The Short List: #{self.title}"
    EloquaEmail.new({
      :emailable     => self,
      :html_template   => "/editions/email/template",
      :plain_text_template   => "/editions/email/template",
      :name        => "[tsl #{Time.zone.now.strftime("%Y%m%d")}] #{self.title[0..30]}",
      :description => "SCPR Short List\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{subject}",
      :subject     => subject,
      :email       => "theshortlist@scpr.org",
      :email_type  => "shortlist"
    }).plain_text_body
  end

  def monday_text_body
    # NOTE: This is ugly as hell but will only be around for the short term.
    # Please, PLEASE remove this ASAP.

    subject = "The Short List: #{self.title}"
    EloquaEmail.new({
      :emailable     => self,
      :html_template   => "/editions/email/monday/template",
      :plain_text_template   => "/editions/email/monday/template",
      :name        => "[tslm #{Time.zone.now.strftime("%Y%m%d")}] #{self.title[0..30]}",
      :description => "SCPR Monday Short List\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{subject}",
      :subject     => subject,
      :email       => "theshortlist@scpr.org",
      :email_type  => "monday_shortlist"
    }).plain_text_body
  end

  def send_shortlist_email
    subject = "The Short List: #{self.title}"
    eloqua_emails.create({
      :html_template   => "/editions/email/template",
      :plain_text_template   => "/editions/email/template",
      :name        => "[tsl #{Time.zone.now.strftime("%Y%m%d")}] #{self.title[0..30]}",
      :description => "SCPR Short List\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{subject}",
      :subject     => subject,
      :email       => "theshortlist@scpr.org",
      :email_type  => "shortlist"
    })
  end

  def send_monday_email
    subject = "The Short List: #{self.title}"
    eloqua_emails.create({
      :html_template   => "/editions/email/monday/template",
      :plain_text_template   => "/editions/email/monday/template",
      :name        => "[tslm #{Time.zone.now.strftime("%Y%m%d")}] #{self.title[0..30]}",
      :description => "SCPR Monday Short List\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{subject}",
      :subject     => subject,
      :email       => "theshortlist@scpr.org",
      :email_type  => "monday_shortlist"
    })
  end

  def shortlist_email_sent?
    email_sent? "shortlist"
  end

  def monday_email_sent?
    email_sent? "monday_shortlist"
  end

  def view
    @view ||= CacheController.new
  end

  # Checks if a specific email type was sent
  def email_sent? email_type
    send "#{email_type}_email_sent"
  end



  # We can't use `publishing?` here because this gets checked in
  # a background worker.
  def should_send_shortlist_email?
    published? && !shortlist_email_sent?
  end

  def should_send_monday_email?
    published? && !monday_email_sent? && Time.zone.now.to_date.monday?
  end

  def should_send_email?
    should_send_shortlist_email? || should_send_monday_email?
  end

  private

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

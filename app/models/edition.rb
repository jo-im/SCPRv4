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
  include Concern::Methods::EloquaSendable


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


  ### EloquaSendable interface implementation
  # Note that we don't check for presence of first Abstract before trying to
  # use it (in the templates). We probably should, but trying to send out an
  # edition without any abstracts would be a mistake, so errors are okay now.
  # Maybe we should just validate that at least one item slot is present.
  def as_eloqua_email
    subject = "#{self.title}: #{self.abstracts.first.headline}"

    {
      :html_body => view.render_view(
        :template   => "/editions/email/template",
        :formats    => [:html],
        :locals     => { edition: self }).to_s,

      :plain_text_body => view.render_view(
        :template   => "/editions/email/template",
        :formats    => [:text],
        :locals     => { edition: self }).to_s,

      :name        => "[scpr-edition] #{self.title[0..30]}",
      :description => "SCPR Short List\n" \
                      "Sent: #{Time.now}\nSubject: #{subject}",
      :subject     => subject
    }
  end


  private

  # We can't use `publishing?` here because this gets checked in
  # a background worker.
  def should_send_email?
    self.published? && !self.email_sent?
  end

  def update_email_status(email, campaign)
    self.update_column(:email_sent, true)
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

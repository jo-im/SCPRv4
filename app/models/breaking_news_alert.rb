class BreakingNewsAlert < ActiveRecord::Base
  self.table_name = 'layout_breakingnewsalert'
  outpost_model
  has_secretary
  has_status


  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Methods::StatusMethods
  include Concern::Methods::EloquaSendable

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  ALERT_TYPES = {
    "break"   => "Breaking News",
    "audio"   => "Listen Live",
    "now"     => "Happening Now"
  }


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

  status :published do |s|
    s.id = 5
    s.text = "Published"
    s.published!
  end


  PARSE_CHANNEL         = "breakingNews"
  FRAGMENT_EXPIRE_KEY   = "layout/breaking_news_alert"


  # Don't use PublishedScope because this model
  # uses :published instead of :live
  scope :published, -> {
    where(status: self.status_id(:published))
    .order("published_at desc")
  }

  scope :visible, -> { where(visible: true) }

  #-------------------
  # Associations

  #-------------------
  # Validations
  validates \
    :headline,
    :alert_type,
    :status,
    presence: true

  validates :alert_url, url: { allow_blank: true }

  #-------------------
  # Callbacks
  after_save :async_send_email,
    :if => :should_send_email?

  after_save :async_send_mobile_notification,
    :if => :should_send_mobile_notification?

  after_commit :expire_alert_fragment

  #-------------------

  class << self
    # Get the latest published alert, whether visible or not,
    # and check if it's visible.
    def latest_alert
      alert = self.published.first
      alert.try(:visible?) ? alert : nil
    end

    def types_select_collection
      ALERT_TYPES.map { |k, v| [v, k] }
    end

    def expire_alert_fragment
      Rails.cache.expire_obj(FRAGMENT_EXPIRE_KEY)
    end
  end


  # Callbacks will handle the email/push notification
  def publish
    self.update_attributes(status: self.class.status_id(:published))
  end


  def async_send_mobile_notification
    Resque.enqueue(Job::SendBreakingNewsMobileNotification, self.id)
  end


  # Publish a mobile notification
  def publish_mobile_notification
    return false if !should_send_mobile_notification?

    push = Parse::Push.new({
      :title      => "KPCC - #{self.break_type}",
      :alert      => self.email_subject,
      :badge      => "Increment",
      :alertId    => self.id
    }, PARSE_CHANNEL)

    result = push.save

    if result["result"] == true
      self.update_column(:mobile_notification_sent, true)
    else
      # TODO: Handle errors from Parse
    end
  end

  add_transaction_tracer :publish_mobile_notification, category: :task


  def break_type
    ALERT_TYPES[alert_type]
  end



  ### EloquaSendable interface implementation

  def email_html_body
    @email_html_body ||= view.render_view(
      :template   => "/breaking_news/email/template",
      :formats    => [:html],
      :locals     => { alert: self }
    ).to_s
  end

  def email_plain_text_body
    @email_plain_text_body ||= view.render_view(
      :template   => "/breaking_news/email/template",
      :formats    => [:text],
      :locals     => { alert: self }
    ).to_s
  end

  def email_name
    @email_name ||= "[scpr-alert] #{self.headline[0..30]}"
  end

  def email_description
    @email_description ||=
      "SCPR Breaking News Alert\n" \
      "Sent: #{Time.now}\nSubject: #{email_subject}"
  end

  def email_subject
    @email_subject ||= "#{break_type}: #{headline}"
  end

  def should_send_email?
    self.published? &&
    self.send_email? &&
    !self.email_sent?
  end


  private

  def should_send_mobile_notification?
    self.published? &&
    self.send_mobile_notification? &&
    !self.mobile_notification_sent?
  end

  def expire_alert_fragment
    BreakingNewsAlert.expire_alert_fragment
  end
end

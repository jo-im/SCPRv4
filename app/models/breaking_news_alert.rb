class BreakingNewsAlert < ActiveRecord::Base
  self.table_name = 'layout_breakingnewsalert'
  outpost_model
  has_secretary
  has_status


  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Methods::EloquaSendable

  include Concern::Model::Searchable

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  include Concern::Sanitizers::Url

  before_validation ->{ sanitize_urls :alert_url }

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


  IPAD_CHANNEL          = "breakingNews"
  IPHONE_CHANNEL        = "listenLive"
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

  #after_commit :expire_alert_fragment

  #-------------------

  class << self
    # Get the latest published and visible alert.
    def latest_visible_alert
      self.published.visible.first
    end

    def types_select_collection
      ALERT_TYPES.map { |k, v| [v, k] }
    end

    #def expire_alert_fragment
    #  Rails.cache.expire_obj(FRAGMENT_EXPIRE_KEY)
    #end
  end


  # Callbacks will handle the email/push notification
  def publish
    self.update_attributes(status: self.class.status_id(:published))
  end


  def async_send_mobile_notification
    Resque.enqueue(Job::SendMobileNotification, self.class.name, self.id)
  end


  # Publish a mobile notification
  def publish_mobile_notification
    return false if !should_send_mobile_notification?
    response = one_signal_push
    self.update_column(:mobile_notification_sent, true)
  rescue OneSignal::OneSignalError, OneSignal::NoRecipientsError => err
    NewRelic.log_error(err)
  end

  def one_signal_push
    params = {
      app_id:     Rails.application.secrets.api['one_signal']['app_id'],
      headings: {
        en: "KPCC - #{self.break_type}"
      },
      contents: {
        en: alert_subject.to_s
      },
      data: {
        title: "KPCC - #{self.break_type}",
        alert_id: self.id.to_s
      },
      included_segments: ["Active Users"]
    }
    if badge == "Increment"
      params[:ios_badgeType]  = "Increase"
      params[:ios_badgeCount] = 1
    end
    OneSignal::Notification.create(params: params)
  end

  add_transaction_tracer :publish_mobile_notification, category: :task


  def break_type
    ALERT_TYPES[alert_type]
  end



  # EloquaSendable interface implementation
  # This isn't memoized because if we update the BreakingNewsAlert
  # object, we want those changes to be reflected here as well, without
  # having to reload the object.
  def as_eloqua_email
    {
      :html_body => view.render_view(
        :template   => "/breaking_news/email/template",
        :formats    => [:html],
        :locals     => { alert: self }).to_s,

      :plain_text_body => view.render_view(
        :template   => "/breaking_news/email/template",
        :formats    => [:text],
        :locals     => { alert: self }).to_s,

      :name        => "[alert #{Time.zone.now.strftime("%Y%m%d")}] #{self.headline[0..30]}",
      :description => "SCPR Breaking News Alert\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{alert_subject}",
      :subject     => alert_subject,
      :email       => "no-reply@kpcc.org"
    }
  end

  def html_body
    as_eloqua_email[:html_body]
  end

  def text_body
    as_eloqua_email[:plain_text_body]
  end

  def badge
    unless alert_type == "audio"
      "Increment"
    end
  end

  private

  def should_send_email?
    self.published? &&
    self.send_email? &&
    !self.email_sent?
  end

  def update_email_status(campaign)
    if campaign.activate
      self.update_column(:email_sent, true)
    end
  end


  # Since we use this same text for mobile notifications and
  # Eloqua e-mails, define it here.
  def alert_subject
    "#{break_type}: #{headline}"
  end

  def should_send_mobile_notification?
    self.published? &&
    self.send_mobile_notification? &&
    !self.mobile_notification_sent?
  end

  #def expire_alert_fragment
  #  BreakingNewsAlert.expire_alert_fragment
  #end
end

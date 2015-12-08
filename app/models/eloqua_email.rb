class EloquaEmail < ActiveRecord::Base
  include Concern::Methods::EloquaSendable 
  alias_attribute :sent?, :email_sent
  after_save :async_send_email, if: :not_sent? # enqueues the record in Resque, which then calls #publish_email on the record
  belongs_to :emailable, polymorphic: true

  scope :unsent, ->{ where(email_sent: false).where(attempts_made: 1..2) }

  ## This method is named this way in order to make it compatible
  ## with the way that EloquaSendbale already works.  Perhaps
  ## it should be globally renamed in the future to prevent
  ## confusion.
  def as_eloqua_email
    email_object = {
      :name        => name,
      :description => description,
      :subject     => subject,
      :email       => email,
      :email_type  => email_type
    }

    email_object.merge!({html_body: html_body}) if html_body
    email_object.merge!({plain_text_body: plain_text_body}) if plain_text_body
    email_object
  end

  def html_body
    if html_template
      view.render_view(
        :template   => html_template,
        :formats    => [:html],
        :locals     => locals
      ).to_s
    end
  end

  def plain_text_body
    if html_template
      view.render_view(
        :template   => plain_text_template,
        :formats    => [:text],
        :locals     => locals
      ).to_s
    end
  end

  def update_email_status campaign
    update_column(:email_sent, true)
    if email_type && emailable.respond_to?("#{email_type}_email_sent")
      emailable.update_column("#{email_type}_email_sent", true)
    end
  end

  def should_send_email?
    !sent?
  end

  def not_sent?
    sent? != true
  end

  def obj_name
    email_type || (emailable ? emailable.class.name : nil) || self.class.name
  end

  def publish_email options={}
    super
  rescue => e
    NewRelic.log_error(e)
  ensure
    self.attempts_made += 1
    save
  end

  private

  def locals
    emailable ? { emailable.class.name.underscore.to_sym => emailable } : {}
  end
end
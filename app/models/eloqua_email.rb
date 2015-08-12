class EloquaEmail < ActiveRecord::Base
  include Concern::Methods::EloquaSendable 
  alias_attribute :sent?, :email_sent
  after_save :async_send_email, if: :not_sent? # enqueues the record in Resque, which then calls #publish_email on the record
  belongs_to :emailable, polymorphic: true

  def as_eloqua_email
    {
      :html_body => view.render_view(
        :template   => html_template,
        :formats    => [:html],
        :locals     => { emailable.class.name.underscore.to_sym => emailable }).to_s,

      :plain_text_body => view.render_view(
        :template   => plain_text_template,
        :formats    => [:text],
        :locals     => { emailable.class.name.underscore.to_sym => emailable }).to_s,

      :name        => name,
      :description => "#{description}\n" \
                      "Sent: #{Time.zone.now}\nSubject: #{subject}",
      :subject     => subject,
      :email       => email,
      :email_type  => email_type
    }
  end

  def update_email_status campaign
    update_column(:email_sent, true)
    if email_type && emailable.respond_to?("#{email_type}_email_type")
      emailable.update_column("#{email_type}_email_type", true)
    end
  end

  def should_send_email?
    !sent?
  end

  def not_sent?
    sent? != true
  end
end

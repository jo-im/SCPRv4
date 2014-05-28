##
# ContentEmail
#
# An e-mail associated with any object
#
class ContentEmail
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor \
    :from_name,
    :from_email,
    :to_email,
    :body,
    :content_key


  validates :from_email, :to_email,
    :presence => true,
    :format   => {
      :with       => %r{\A\S+?@\S+?\.\S+\z},
      :message    => "is an invalid e-mail format."
    }

  validates :content_key, presence: true
  validate :content_is_allowed

  #---------------

  # Don't use symbolize_keys! here, since we're passing in
  # form fields directly to this initializer, that would open
  # us to DDoS attacks.
  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access

    @to_email     = attributes[:to_email]
    @from_email   = attributes[:from_email]
    @from_name    = attributes[:from_name]
    @body         = attributes[:body]
  end

  #---------------

  def persisted?
   false
  end

  #---------------

  def save
    return false unless self.valid?

    Job::DelayedMailer.enqueue("ContentMailer", :email_content,
      [self.to_json, self.content_key])

    self
  end


  def to_json
    {
      :to_email     => self.to_email,
      :from_email   => self.from_email,
      :from_name    => self.from_name,
      :body         => self.body
    }
  end

  #---------------

  def from
    if self.from_name.present?
      self.from_name
    else
      self.from_email
    end
  end


  private

  # We want to keep the validation message intentionally obtuse for
  # potential attackers.
  # Yes, I realize that this comment is publicly visible.
  def content_is_allowed
    if !ContentBase.safe_obj_by_key(self.content_key)
      errors.add(:base, "Invalid Message")
    end
  end
end

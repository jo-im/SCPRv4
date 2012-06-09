class AdminUser < ActiveRecord::Base  
  self.table_name = "auth_user"
  
  include ActiveModel::SecureAttribute
  has_secure_attribute :passw
  attr_accessor :passw_confirmation
  
  before_validation :downcase_email
  
  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true

  before_create :generate_username
  before_create { generate_token(:auth_token) }
  
  scope :active, where(:is_active => true)
  
  def self.authenticate(username, password)
    if user = find_by_username(username)
      user.authenticate_legacy(password)
    else
      false
    end
  end
  
  def authenticate_legacy(password)
    algorithm, salt, hash = self.password.split('$')
    if hash == Digest::SHA1.hexdigest(salt + password)
      self.passw, self.passw_confirmation = password
      generate_token(:auth_token)
      save!
      self
    else
      false
    end
  end
  
  def as_json(*args)
    {
      id: self.id,
      username: self.username,
      name: self.name,
      email: self.email,
      is_superuser: self.is_superuser
    }
  end
      
  protected
  
    def downcase_email # This helps us validate that e-mails are unique, because the case_sensitive validation is slow.
      self.email = email.downcase if email.present?
    end
    
    def generate_username
      split_name = self.name.split(" ", 2)
      username = (split_name[0].chars.first + split_name[1].gsub(/\W/, "")).downcase
      if !AdminUser.find_by_username(username)
        self.username = username
      else
        i = 1
        begin
          self.username = username + i.to_s
          i += 1
        end while AdminUser.exists?(username: self.username)
      end
    end
    
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while AdminUser.exists?(column => self[column])
    end
end

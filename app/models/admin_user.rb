class AdminUser < ActiveRecord::Base
  self.table_name = 'auth_user'
  outpost_model
  has_secretary

  include Outpost::Model::Authentication
  include Outpost::Model::Authorization

  include Concern::Model::Searchable

  self.unversioned_attributes = ['password_digest']

  before_validation :generate_username,
    :on => :create,
    :if => -> { self.username.blank? }

  has_one  :bio, foreign_key: "user_id"


  class << self
    def select_collection
      AdminUser.order("name").map { |u| [u.to_title, u.id] }
    end
  end


  def json
    {
      :username     => self.username,
      :name         => self.name,
      :email        => self.email,
      :is_superuser => self.is_superuser,
      :headshot     => self.bio.try(:headshot) ? self.bio.headshot.thumb.url : nil
    }
  end


  private

  # Generate a username based on real name
  #
  # Returns String of the username
  def generate_username
    return nil if !self.name.present?

    names       = self.name.to_s.split
    base        = (names.first.chars.first + names.last).downcase.gsub(/\W/, "")
    dirty_name  = base

    i = 1
    while self.class.exists?(username: dirty_name)
      dirty_name = base + i.to_s
      i += 1
    end

    self.username = dirty_name
  end
end

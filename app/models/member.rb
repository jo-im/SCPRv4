class Member < ActiveRecord::Base
  validates :pledge_token, presence: true
end

class Embed < ActiveRecord::Base
  validates :url, url: true, presence: true
end

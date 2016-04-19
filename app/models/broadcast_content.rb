class BroadcastContent < ActiveRecord::Base
  outpost_model
  has_secretary
  belongs_to :content, polymorphic: true
end

class BroadcastContent < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status
  include Concern::Associations::RelatedContentAssociation
  include Concern::Associations::AudioAssociation
  include Concern::Methods::ArticleStatuses
  belongs_to :content, polymorphic: true
end
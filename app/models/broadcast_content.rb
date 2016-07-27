class BroadcastContent < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status
  include Concern::Associations::RelatedContentAssociation
  include Concern::Associations::AudioAssociation
  include Concern::Methods::ArticleStatuses
  belongs_to :content, polymorphic: true
  after_save :touch_relations

  def touch_relations
    # So that broadcast content can be associated
    # with the associated contents' pmp document
    # if we create broadcast content after initial publish
    related_content.each{|r| r.original_object.try(:touch)}
  end
end
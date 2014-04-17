class Quote < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Callbacks::SphinxIndexCallback

  belongs_to :content,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic => true

  accepts_json_input_for :content


  def article
    self.content.try(:to_article)
  end


  private

  def build_content_association(content_hash, content)
    if content.published?
      self.content = content
    end
  end
end

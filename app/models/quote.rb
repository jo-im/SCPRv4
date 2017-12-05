class Quote < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Model::Searchable

  belongs_to :content,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic => true

  accepts_json_input_for :content

  # This is here so the foreign key on Vertical will be cleared out if this
  # quote is destroyed. Note that the :nullify option doesn't run callbacks
  # on the associated record, so the cache won't be cleared. This is good
  # enough, because Quotes are no longer editable outside of the context
  # of a Vertical.
  has_many :verticals, dependent: :nullify
  has_many :kpcc_programs, dependent: :nullify

  validates :text, presence: true


  def article
    self.content
  end


  private

  def build_content_association(content_hash, content)
    if content.published?
      self.content = content
    end
  end
end

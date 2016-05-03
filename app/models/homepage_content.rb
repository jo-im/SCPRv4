class HomepageContent < ActiveRecord::Base
  include Outpost::Aggregator::SimpleJson

  ASSET_DISPLAY = {
    default: 'medium',
    display_types: [
      'none',
      'medium',
      'large'
    ]
  }

  self.table_name = "layout_homepagecontent"
  self.versioned_attributes = ["content_type", "content_id", "position"]

  # FIXME: Can we figure out a way not to reference ContentBase here?
  # The problem is that "content" can be something that does use the
  # ContentBase statuses, like Event or PijQuery.
  # I suppose we could just switch back to always referencing ContentBase
  # _only_ for the "live" statuses. Not great but right now it's dangerous,
  # if someone changes one of those status numbers on another class then
  # that class won't show up on the Homepage.
  belongs_to :content,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic    => true

  belongs_to :homepage, polymorphic: true

  after_initialize :set_default_asset_display

  def simple_json
    @simple_json = super.merge({'asset_display' => self.asset_display})
  end

  def label
    if content
      return "KPCC In Person" if content.try(:is_kpcc_event)
      tags = (content.try(:tags) || [])
      keyword = tags.find{|t| t.try(:tag_type).try(:include?, 'Keyword')}
      program = content.try(:show)
      series  = tags.find{|t| t.try(:tag_type).try(:include?, 'Series')}
      beat    = tags.find{|t| t.try(:tag_type).try(:include?, 'Beat')}
      [beat, series, program, keyword].compact.map(&:title).first
    end
  end

  def to_index
    if content
      OpenStruct.new(
        {
          obj_key: content.obj_key,
          content_id: content_id,
          asset_display: asset_display,
          position: position,
          label: label
        }
      )
    else
      {}
    end
  end

  private

  def set_default_asset_display
    @asset_display ||= ASSET_DISPLAY[:default]
  end
end

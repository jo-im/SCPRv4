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

  after_initialize :set_default_asset_scheme

  def simple_json
    @simple_json = super.merge({'asset_scheme' => self.asset_scheme})
  end

  def label
    if content
      return "KPCC In Person" if content.try(:is_kpcc_event)
      tags = (content.try(:tags) || [])
      (
        tags.find{|t| t.try(:tag_type).try(:include?, 'Keyword')} ||  # keyword
        content.try(:show) ||                                         # program
        tags.find{|t| t.try(:tag_type).try(:include?, 'Series')} ||   # series
        tags.find{|t| t.try(:tag_type).try(:include?, 'Beat')} ||     # beat
        content.try(:category)                                        # category
      ).try(:title)
    end
  end

  def call_to_action
    return if !content
    case content_type
    when "ShowSegment"
      if content.show.try(:slug) == 'airtalk'
        "conversation"
      else
        "podcast"
      end
    when "Event"
      if !(content.rsvp_url || "").empty?
        "event"
      end
    end
  end

  def to_indexable
    if content
      OpenStruct.new(
        {
          obj_key: content.obj_key,
          content_id: content_id,
          asset_scheme: asset_scheme,
          position: position,
          label: label,
          call_to_action: call_to_action
        }
      )
    else
      {}
    end
  end

  private

  def set_default_asset_scheme
    @asset_scheme ||= ASSET_DISPLAY[:default]
  end
end

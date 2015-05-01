class ShowRundown < ActiveRecord::Base
  self.table_name = 'shows_rundown'
  self.versioned_attributes = ["segment_id", "position"]

  belongs_to :episode, class_name: "ShowEpisode", inverse_of: :rundowns
  belongs_to :segment, class_name: "ShowSegment", inverse_of: :rundowns

  validates :episode_id, presence:true
  validates :segment_id, presence:true

  #------------------------

  def simple_json
    {
      "id"       => self.segment.try(:obj_key), # TODO Store this in join table
      "position" => self.position.to_i
    }
  end

  before_create :check_position, if: -> { self.position.blank? }

  def check_position
    if last_rundown = ShowRundown.where(episode_id: episode.id).last
      self.position = last_rundown.position + 1
    else
      self.position = 1
    end
  end
end

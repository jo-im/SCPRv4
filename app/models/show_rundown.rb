class ShowRundown < ActiveRecord::Base
  self.table_name = 'shows_rundown'
  self.versioned_attributes = ["segment_id", "position"]

  belongs_to :episode, class_name: "ShowEpisode", inverse_of: :rundowns
  belongs_to :segment, class_name: "ShowSegment", inverse_of: :rundowns

  validates :episode, presence:true, associated:true
  validates :segment, presence:true, associated:true

  #------------------------

  def simple_json
    {
      "id"       => self.segment.try(:obj_key), # TODO Store this in join table
      "position" => self.position.to_i
    }
  end
end

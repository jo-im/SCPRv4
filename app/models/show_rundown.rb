class ShowRundown < ActiveRecord::Base
  self.table_name = 'shows_rundown'
  self.versioned_attributes = ["content_id", "position"]

  belongs_to :episode, class_name: "ShowEpisode", inverse_of: :rundowns
  belongs_to :content, polymorphic: true

  validates :episode, presence:true, associated:true
  validates :content, presence:true, associated:true

  #------------------------

  def simple_json
    {
      "id"       => self.content.try(:obj_key), # TODO Store this in join table
      "type"     => self.content_type,
      "position" => self.position.to_i
    }
  end
end

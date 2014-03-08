class ShowRundown < ActiveRecord::Base
  self.table_name = 'shows_rundown'
  self.versioned_attributes = ["content_type", "content_id", "position"]

  belongs_to :episode, class_name: "ShowEpisode"
  belongs_to :content, polymorphic: true

  #------------------------

  def simple_json
    {
      "id"       => self.content.try(:obj_key), # TODO Store this in join table
      "position" => self.position.to_i
    }
  end

  before_create :check_position, if: -> { self.position.blank? }

  def check_position
    if last_rundown = ShowRundown.where(episode_id: self.episode_id).last
      self.position = last_rundown.position + 1
    else
      self.position = 1
    end
  end
end

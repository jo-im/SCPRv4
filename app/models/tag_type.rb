class TagType < ActiveRecord::Base
  outpost_model
  has_many :tags

  def tag_count
    tags.count
  end
end
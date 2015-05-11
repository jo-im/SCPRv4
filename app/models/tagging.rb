class Tagging < ActiveRecord::Base
  belongs_to :tag, touch: true
  belongs_to :taggable, polymorphic: true, touch: true
end

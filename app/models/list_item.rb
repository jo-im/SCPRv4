class ListItem < ActiveRecord::Base
  belongs_to :list
  belongs_to :item, polymorphic: true

  scope :articles, -> { order('position ASC').map(&:item).map(&:get_article) }
end

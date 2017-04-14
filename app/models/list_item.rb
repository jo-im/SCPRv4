class ListItem < ActiveRecord::Base
  include Outpost::Aggregator::SimpleJson

  belongs_to :list
  belongs_to :item, polymorphic: true

  alias_attribute :content, :item

  scope :articles, -> { order('position ASC').map(&:item).map(&:get_article) }
end

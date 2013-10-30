class CategoryArticle < ActiveRecord::Base
  belongs_to :category
  belongs_to :article, polymorphic: true
  attr_accessible :position
end

class CategoryReporter < ActiveRecord::Base
  belongs_to :category
  belongs_to :bio
  # attr_accessible :title, :body
end

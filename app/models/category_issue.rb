class CategoryIssue < ActiveRecord::Base
  belongs_to :category
  belongs_to :issue
  # attr_accessible :title, :body
end

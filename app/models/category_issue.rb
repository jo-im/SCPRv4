class CategoryIssue < ActiveRecord::Base
  belongs_to :category
  belongs_to :issue
end

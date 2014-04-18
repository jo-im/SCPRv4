class VerticalIssue < ActiveRecord::Base
  self.table_name = "category_issues"

  belongs_to :category
  belongs_to :vertical
  belongs_to :issue
end

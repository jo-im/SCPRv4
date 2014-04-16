class VerticalReporter < ActiveRecord::Base
  self.table_name = "category_reporters"

  belongs_to :category
  belongs_to :vertical
  belongs_to :bio
end

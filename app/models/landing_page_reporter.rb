class LandingPageReporter < ActiveRecord::Base
  self.table_name = "landing_page_reporters"

  belongs_to :vertical
  belongs_to :bio
end

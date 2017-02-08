# This class stores a landing page's featured contents
#
# The LandingPage -> Content association is made through a
# LandingPage's featured contents (this class).

class LandingPageContent < ActiveRecord::Base
  self.table_name = "landing_page_contents"

  belongs_to :landing_page

  belongs_to :article,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic => true


  def simple_json
    @simple_json ||= {
      "id"          => self.article.try(:obj_key),
      "position"    => self.position.to_i
    }
  end
end

# This class stores a vertical's featured articles
#
# The Vertical -> Article association is made through a
# Vertical's featured articles (this class).
#
# The Article -> Vertical association is done through the
# Article's category. It is then implicitly tied to that
# category's vertical (if present).
class VerticalArticle < ActiveRecord::Base
  self.table_name = "category_articles"

  belongs_to :category
  belongs_to :vertical

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

class CategoryArticle < ActiveRecord::Base
  belongs_to :category

  belongs_to :article,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic    => true


  def simple_json
    @simple_json ||= {
      "id"          => self.article.try(:obj_key),
      "position"    => self.position.to_i
    }
  end
end

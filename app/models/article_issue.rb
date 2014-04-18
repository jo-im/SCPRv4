class ArticleIssue < ActiveRecord::Base
  belongs_to :issue

  belongs_to :article,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic => true
end

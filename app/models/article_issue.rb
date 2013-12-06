class ArticleIssue < ActiveRecord::Base
  belongs_to :issue

  belongs_to :article,
    :polymorphic => true,
    :conditions  => { status: ContentBase::STATUS_LIVE }
end

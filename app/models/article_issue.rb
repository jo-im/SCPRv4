class ArticleIssue < ActiveRecord::Base
  belongs_to :issue
  belongs_to :article, polymorphic: true
end

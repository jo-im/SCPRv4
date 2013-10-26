class ArticleIssue < ActiveRecord::Base
  belongs_to :issue
  belongs_to :article, polymorphic: true
  # attr_accessible :title, :body
end

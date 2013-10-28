ThinkingSphinx::Index.define :abstract, with: :active_record do
  indexes headline
  indexes summary
  indexes url
  has :source
  has updated_at
  has article_published_at
  has category.id, as: :category

  # For ContentBase.search
  has created_at, as: :public_datetime
  has "1",
    :type   => :boolean,
    :as     => :is_live
end

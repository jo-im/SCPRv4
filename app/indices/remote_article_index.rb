ThinkingSphinx::Index.define :remote_article, with: :active_record do
  indexes headline
  indexes teaser
  indexes article_id
  indexes :source
  has published_at
end

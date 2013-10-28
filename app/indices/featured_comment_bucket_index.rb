ThinkingSphinx::Index.define :featured_comment_bucket, with: :active_record do
  indexes title, sortable: true
  has created_at
  has updated_at
end

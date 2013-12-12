ThinkingSphinx::Index.define :featured_comment, with: :active_record do
  indexes username
  indexes excerpt

  has created_at
  has bucket_id
  has status
end

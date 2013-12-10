ThinkingSphinx::Index.define :edition, with: :active_record do
  indexes title

  has updated_at
  has published_at
  has status
end

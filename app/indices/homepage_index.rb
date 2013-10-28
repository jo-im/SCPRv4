ThinkingSphinx::Index.define :homepage, with: :active_record do
  indexes base
  has published_at
  has updated_at
end

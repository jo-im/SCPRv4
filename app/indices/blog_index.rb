ThinkingSphinx::Index.define :blog, with: :active_record do
  indexes name
  indexes teaser
  has is_active
end

ThinkingSphinx::Index.define :tag, with: :active_record do
  indexes title, sortable: true
  indexes slug, sortable: true

  has created_at
end

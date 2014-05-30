ThinkingSphinx::Index.define :tag, with: :active_record do
  indexes title, sortable: true
  indexes slug, sortable: true

  indexes description

  has is_featured
  has created_at
end

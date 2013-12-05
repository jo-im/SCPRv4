ThinkingSphinx::Index.define :issue, with: :active_record do
  indexes title, sortable: true
  indexes slug, sortable: true
  indexes description

  has is_active
  has created_at
end

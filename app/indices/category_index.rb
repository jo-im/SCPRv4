ThinkingSphinx::Index.define :category, with: :active_record do
  indexes title, sortable: true
  indexes slug, sortable: true
end

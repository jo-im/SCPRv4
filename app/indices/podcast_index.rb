ThinkingSphinx::Index.define :podcast, with: :active_record do
  indexes title, sortable: true
  indexes slug
  indexes description
end

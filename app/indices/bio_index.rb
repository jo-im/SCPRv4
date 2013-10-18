ThinkingSphinx::Index.define :bio, with: :active_record do
  indexes name, sortable: true
  indexes title
  indexes email
end

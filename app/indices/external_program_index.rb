ThinkingSphinx::Index.define :external_program, with: :active_record do
  indexes title, sortable: true
  indexes description
  indexes host
  indexes organization
end

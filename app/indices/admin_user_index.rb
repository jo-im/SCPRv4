ThinkingSphinx::Index.define :admin_user, with: :active_record do
  indexes username
  indexes name, sortable: true
end

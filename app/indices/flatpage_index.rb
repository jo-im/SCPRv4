ThinkingSphinx::Index.define :flatpage, with: :active_record do
  indexes path, sortable: true
  indexes title
  indexes description
  indexes redirect_to
  has updated_at
end

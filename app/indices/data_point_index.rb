ThinkingSphinx::Index.define :data_point, with: :active_record do
  indexes title
  indexes data_key, sortable: true
  indexes data_value
  indexes group_name, sortable: true
  has updated_at
end

ThinkingSphinx::Index.define :missed_it_bucket, with: :active_record do
  indexes title, sortable: true
end

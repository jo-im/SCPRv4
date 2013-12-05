ThinkingSphinx::Index.define :quote, with: :active_record do
  indexes quote
  indexes source_name
  indexes source_context

  has category_id, as: :category
  has status
  has created_at
end

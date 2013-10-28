ThinkingSphinx::Index.define :featured_comment, with: :active_record do
  indexes username
  indexes excerpt
end

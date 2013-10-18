ThinkingSphinx::Index.define :press_release, with: :active_record do
  indexes title
  indexes body
  has created_at
end

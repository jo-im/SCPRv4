ThinkingSphinx::Index.define :schedule_occurrence, with: :active_record do
  indexes event_title
  indexes program.title
  indexes info_url
  has updated_at
  has starts_at

  polymorphs program,
    to: %w(KpccProgram ExternalProgram)
end

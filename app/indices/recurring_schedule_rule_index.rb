ThinkingSphinx::Index.define :recurring_schedule_rule, with: :active_record do
  has :id # just so the Search in outpost can be ordered.
  indexes program.title
  indexes schedule_hash

  polymorphs program,
    to: %w(KpccProgram ExternalProgram)
end

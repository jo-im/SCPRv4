ThinkingSphinx::Index.define :kpcc_program, with: :active_record do
  indexes title, sortable: true
  indexes airtime
  indexes description
  indexes host
end

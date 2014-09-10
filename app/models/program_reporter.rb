class ProgramReporter < ActiveRecord::Base

  belongs_to :kpcc_program, :foreign_key => "program_id"
  belongs_to :bio
end


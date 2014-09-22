require 'spec_helper'

describe ProgramReporter do
  subject { build :program_reporter }

  it { should belong_to :kpcc_program }
  it { should belong_to :bio }
end


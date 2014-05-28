require 'spec_helper'

describe VerticalReporter do
  subject { build :vertical_reporter }

  it { should belong_to :vertical }
  it { should belong_to :bio }
end

require 'spec_helper'

describe VerticalIssue do
  subject { build :vertical_issue }

  it { should belong_to :vertical }
  it { should belong_to :issue }
end

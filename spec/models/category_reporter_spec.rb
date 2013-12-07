require 'spec_helper'

describe CategoryReporter do
  subject { build :category_reporter }

  it { should belong_to :category }
  it { should belong_to :bio }
end

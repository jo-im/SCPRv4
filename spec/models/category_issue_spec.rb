require 'spec_helper'

describe CategoryIssue do
  subject { build :category_issue }

  it { should belong_to :category }
  it { should belong_to :issue }

  # \o/   B)-/<   <^_^<
end
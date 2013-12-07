require "spec_helper"

describe Concern::Associations::CategoryAssociation do
  subject { build :test_class_story }
  it { should belong_to(:category) }
end

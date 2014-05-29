require "spec_helper"

describe Concern::Associations::TagsAssociation do
  subject { create :test_class_story }

  it { should have_many :taggings }
  it { should have_many :tags }
end

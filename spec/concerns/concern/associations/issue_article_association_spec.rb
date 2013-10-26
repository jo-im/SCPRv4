require "spec_helper"

describe Concern::Associations::IssueArticleAssociation do
  subject { TestClass::Story.new }
  
  it { should has_many(:issues) }
end


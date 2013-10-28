require "spec_helper"

describe Concern::Associations::IssueArticleAssociation do
  subject { TestClass::Story.new }
  it { should have_many(:article_issues) }
  it { should have_many(:issues).through(:article_issues) }
end


require "spec_helper"

describe Concern::Associations::CategoryArticleAssociation do
  subject { TestClass::Story.new }
  it { should have_many(:category_articles) }
end



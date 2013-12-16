require "spec_helper"

describe PijQuery do
  describe '#to_article' do
    it 'builds an article out of a pij query' do
      query = build :pij_query
      query.to_article.should be_a Article
    end
  end

  describe '#publish' do
    it 'sets the status to published' do
      pij_query = create :pij_query, :pending
      pij_query.published?.should eq false
      pij_query.publish

      pij_query.reload.published?.should eq true
    end
  end
end

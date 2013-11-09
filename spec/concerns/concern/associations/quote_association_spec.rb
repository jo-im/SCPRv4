require 'spec_helper'

describe Concern::Associations::QuoteAssociation do
  before :each do
    @post = create :test_class_post, :published
    @quote = create :quote, article: @post
    @quote.article(true).should eq @post
  end

  it "destroys the join record on destroy" do
    debugger
    @post.destroy
    @quote.article(true).should eq nil
  end

  it "destroys the join record on unpublish" do
    @post.status = ContentBase::STATUS_PENDING
    @post.save!

    @quote.article(true).should eq nil
    @post.quotes(true).should eq []
  end

  it "doesn't destroy the join records on normal save" do
    @post.headline = "Updated"
    @post.save!

    @quote.article(true).should eq @post
    @post.quotes(true).should eq [@quote]
  end
end


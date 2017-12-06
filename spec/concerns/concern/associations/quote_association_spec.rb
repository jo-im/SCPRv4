require 'spec_helper'

describe Concern::Associations::QuoteAssociation do
  before :each do
    @post = create :test_class_post, :published
    @quote = create :quote, content: @post
    @quote.content(true).should eq @post
  end

  it "#article is the content.to_article" do
    @quote.article.should eq @post
  end

  it "destroys the join record on destroy" do
    @post.destroy
    @quote.content(true).should eq nil
  end

  it "destroys the join record on unpublish" do
    @post.status = @post.class.status_id(:pending)
    @post.save!

    @quote.content(true).should eq nil
    @post.quotes(true).should eq []
  end

  it "doesn't destroy the join records on normal save" do
    @post.headline = "Updated"
    @post.save!

    @quote.content(true).should eq @post
    @post.quotes(true).should eq [@quote]
  end
end

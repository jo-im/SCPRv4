require "spec_helper"

describe PmpStory do
  pmp_story = nil
  before :each do
    pmp_story = create :pmp_story, :published
  end
  describe "#build_doc" do
    before :each do
      stub_request(:get, "https://api-sandbox.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api-sandbox.pmp.io:443', 'User-Agent'=>'PMP Ruby Gem 0.5.6'}).
        to_return(:status => 200, :body => "", :headers => {})
    end
    it "returns a pmp document that matches the content" do
      doc = pmp_story.build_doc
      expect(doc.class).to eq PMP::CollectionDocument
      expect(doc.title).to eq pmp_story.content.headline
      expect(doc.guid).to eq pmp_story.guid
    end
  end
end

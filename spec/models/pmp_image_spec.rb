require "spec_helper"

describe PmpImage do
  describe "#publish" do
    before :each do
      stub_request(:get, "https://api-sandbox.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api-sandbox.pmp.io:443', 'User-Agent'=>'PMP Ruby Gem 0.5.6'}).
        to_return(:status => 200, :body => "", :headers => {})
    end
    context "asset that belongs to KPCC" do
      xit "gets published" do
        pmp_image = build :pmp_image
        pmp_image.stub(:content) {

        }
        pmp_image.publish
        expect(pmp_image.published?).to eq true
      end
    end
    context "asset that belongs to someone else" do
      xit "does not get published" do
        pmp_image = create :pmp_image
        pmp_image.publish
        expect(pmp_image.published?).to eq false
      end
    end
  end
end

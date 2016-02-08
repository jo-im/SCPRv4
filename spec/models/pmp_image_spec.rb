require "spec_helper"

describe PmpImage do
  describe "#publish" do
    before :each do
      stub_request(:get, "https://api-sandbox.pmp.io/").
        with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api-sandbox.pmp.io:443', 'User-Agent'=>'PMP Ruby Gem 0.5.6'}).
        to_return(:status => 200, :body => "", :headers => {})
    end
    context "asset that belongs to KPCC" do
      it "gets published" do
        pmp_image = build :pmp_image
        pmp_image.stub(:content) {
          OpenStruct.new({
            owner: "KPCC"
          })
        }
        pmp_image.stub(:build_doc){
          OpenStruct.new({
            save: true
          })
        }
        expect(pmp_image).to receive(:build_doc)
        pmp_image.publish
      end
    end
    context "asset that belongs to someone else" do
      it "does not get published" do
        pmp_image = create :pmp_image
        expect(pmp_image).not_to receive(:build_doc)
        pmp_image.publish
      end
    end
  end
end

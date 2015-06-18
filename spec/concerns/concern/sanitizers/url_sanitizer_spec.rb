require "spec_helper"

describe Concern::Sanitizers::UrlSanitizer do
  # Don't use a factory here because it fills in attributes that we don't want
  # it to. We don't want the Generate* callbacks to be run.
  subject { 
    fake = Class.new
    fake.class_eval{
      attr_accessor :url
      include Concern::Sanitizers::UrlSanitizer
    }
    fake.new
  }

  context "url contains leading and trailing whitespace" do
    it "removes the whitespaces" do
      subject.url = "  http://exampleurl.com  " 
      subject.sanitize_urls :url
      expect(subject.url).to eq "http://exampleurl.com"
    end
    it "does not mess with inline whitespaces" do
      subject.url = "http://example url.com" 
      subject.sanitize_urls :url
      expect(subject.url).to eq "http://example url.com"
    end
  end

  context "url doesn't contain leading and trailing whitespace" do
    before :each do
      subject.url = "http://exampleurl.com" 
    end
    it "does nothing to the url" do
      subject.sanitize_urls :url
      expect(subject.url).to eq "http://exampleurl.com"
    end
  end

end

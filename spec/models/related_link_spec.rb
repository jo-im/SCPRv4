require "spec_helper"

describe RelatedLink do
  describe 'url validation' do
    it 'should allow e-mail addresses' do
      link = build :related_link, url: "mailto:wat@wat.wat"
      link.should be_valid
    end

    it 'shouldnt allow invalid urls for non-twitter links' do
      link = build :related_link, link_type: 'facebook', url: "badurl"
      link.should be_invalid
    end

    it 'should not validate twitter handles' do
      link = build :related_link, link_type: 'twitter', url: "taketwo"
      link.should be_valid
    end
  end

  describe "domain" do
    it "returns nil if link is blank" do
      link = build :related_link, url: nil
      link.domain.should eq nil
    end

    it "returns the link's host" do
      link = build :related_link, url: "http://scpr.org/news"
      link.domain.should eq "scpr.org"
    end
  end
end

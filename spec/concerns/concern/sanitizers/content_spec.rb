require "spec_helper"

describe Concern::Sanitizers::Content do
  # Don't use a factory here because it fills in attributes that we don't want
  # it to. We don't want the Generate* callbacks to be run.
  subject { 
    # fake = Class.new
    # fake.class_eval{
    #   attr_accessor :body
    #   include Concern::Sanitizers::Content
    # }
    # fake.new
    NewsStory.class_eval{
      attr_accessor :body
      include Concern::Sanitizers::Content
    }
    build :news_story
  }

  context "body of subject contains line break and paragraph break unicode characters" do
    it "removes those characters" do
      subject.body = "linebreak paragraphbreak "
      subject.save
      expect(subject.body).to eq "linebreakparagraphbreak"
    end
  end

end

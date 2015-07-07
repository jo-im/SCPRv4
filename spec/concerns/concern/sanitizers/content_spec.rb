require "spec_helper"

describe Concern::Sanitizers::Content do

  subject { 
    NewsStory.class_eval{
      attr_accessor :body
      include Concern::Sanitizers::Content
    }
    build :news_story
  }

  context "body of subject contains line break and paragraph break unicode characters" do
    it "removes those characters" do
      # the string being assigned below contains both a line break character and paragraph break character
      subject.body = "linebreak paragraphbreak "
      subject.save
      expect(subject.body).to eq "linebreakparagraphbreak"
    end
  end

end

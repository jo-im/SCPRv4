require "spec_helper"

describe HomepageContent do
  it { should belong_to(:homepage) }
  it { should belong_to(:content) }

  describe '#content' do
    it 'gets published content' do
      homepage_content = build :homepage_content
      story = create :news_story, :published
      homepage_content.content = story
      homepage_content.save!

      homepage_content.content(true).should eq story
    end

    it "doesn't get unpublished content" do
      homepage_content = build :homepage_content
      story = create :news_story, :draft
      homepage_content.content = story
      homepage_content.save!

      homepage_content.content(true).should be_nil
    end
  end
end

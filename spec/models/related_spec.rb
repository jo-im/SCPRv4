require "spec_helper"

describe Related do
  it { should belong_to(:related) }
  it { should belong_to(:content) }

  describe '#content' do
    it 'gets published content' do
      related_content = build :related_content, related: create(:content_shell)
      story = create :news_story, :published
      related_content.content = story
      related_content.save!

      related_content.content(true).should eq story
    end

    it "doesn't get unpublished content" do
      related_content = build :related_content, related: create(:content_shell)
      story = create :news_story, :draft
      related_content.content = story
      related_content.save!

      related_content.content(true).should be_nil
    end
  end

  describe '#related' do
    it 'gets published content' do
      related_content = build :related_content, content: create(:content_shell)
      story = create :news_story, :published
      related_content.related = story
      related_content.save!

      related_content.related(true).should eq story
    end

    it "doesn't get unpublished content" do
      related_content = build :related_content, content: create(:content_shell)
      story = create :news_story, :draft
      related_content.related = story
      related_content.save!

      related_content.related(true).should be_nil
    end
  end
end

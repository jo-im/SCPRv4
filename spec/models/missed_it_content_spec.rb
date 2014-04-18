require "spec_helper"

describe MissedItContent do
  it { should belong_to :missed_it_bucket }
  it { should belong_to :content }

  describe '#content' do
    it 'gets published content' do
      missed_it_content = build :missed_it_content
      story = create :news_story, :published
      missed_it_content.content = story
      missed_it_content.save!

      missed_it_content.content(true).should eq story
    end

    it "doesn't get unpublished content" do
      missed_it_content = build :missed_it_content
      story = create :news_story, :draft
      missed_it_content.content = story
      missed_it_content.save!

      missed_it_content.content(true).should be_nil
    end
  end
end

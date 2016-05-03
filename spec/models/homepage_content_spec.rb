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

  describe '#label' do
    let(:homepage_content){build :homepage_content}
    context 'event' do
      context 'content is kpcc event' do
        it 'returns kpcc in person' do
          homepage_content.update content: create(:event, {is_kpcc_event: true})
          expect(homepage_content.label).to eq 'KPCC In Person'
        end
      end
      context 'non kpcc event' do
        it 'doesnt return kpcc in person' do
          homepage_content.update content: create(:event)
          expect(homepage_content.label).not_to eq 'KPCC In Person'
        end
      end
    end
  end
end
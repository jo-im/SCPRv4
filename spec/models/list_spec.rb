require 'spec_helper'

describe List, type: :model do
  describe '#visible' do
    context 'a draft list' do
      it 'is not visible' do
        list = List.create title: "test"
        expect(List.visible).to be_empty
      end
    end
    context 'a live list' do
      it 'is visible' do
        list = List.create title: "test", status: 5
        expect(List.visible).to_not be_empty
      end
    end
    context 'a list with a date range starting in the future' do
      it 'is not visible' do
        list = List.create({
          title: "test",
          status: 5,
          starts_at: Time.now + 10.hours,
          ends_at: Time.now + 11.hours
        })
        expect(List.visible).to be_empty
      end
    end
    context 'a list with a date range overlapping the current time' do
      it 'is visible' do
        list = List.create({
          title: "test",
          status: 5,
          starts_at: Time.now - 10.hours,
          ends_at: Time.now + 11.hours
        })
        expect(List.visible).to_not be_empty
      end
    end
    context 'a list with a start time but no end time' do
      it 'is visible' do
        list = List.create({
          title: "test",
          status: 5,
          starts_at: Time.now - 10.hours
        })
        expect(List.visible).to_not be_empty
      end
    end
  end

  describe Category, :indexing do
    describe '#deduped_category_items' do
      context 'a list of news stories associated with a specific category' do
        it 'is deduped from the latest 16 news stories' do
          category = create :category
          latest_stories = create_list :news_story, 16, category: category, published_at: 1.hour.ago
          oldest_story = create :news_story, category: category, published_at: 2.hours.ago

          list = List.create({
            title: "test",
            status: 5,
            category: category
          })

          expect(list.deduped_category_items.length).to eq 1
          expect(list.deduped_category_items.first.obj_key).to eq oldest_story.obj_key
        end
      end
    end
  end
end

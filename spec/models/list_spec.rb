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
          start_time: Time.now + 10.hours,
          end_time: Time.now + 11.hours
        })
        expect(List.visible).to be_empty
      end
    end
    context 'a list with a date range overlapping the current time' do
      it 'is visible' do
        list = List.create({
          title: "test", 
          status: 5,
          start_time: Time.now - 10.hours,
          end_time: Time.now + 11.hours
        })
        expect(List.visible).to_not be_empty
      end
    end
    context 'a list with a start time but no end time' do
      it 'is visible' do
        list = List.create({
          title: "test", 
          status: 5,
          start_time: Time.now - 10.hours
        })
        expect(List.visible).to_not be_empty
      end
    end
  end
end

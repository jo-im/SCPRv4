require "spec_helper"

Rails.application.configure do
  config.cache_store = :null_store
end


describe Cache do
  describe '#read' do
    context "value exists in cache store" do
      before :each do
        Rails.cache.clear
        Cache.clear
        Rails.cache.write('somekey', '12345')
      end
      it 'returns the value from the cache store' do
        allow(Rails.cache).to receive(:read).and_return("12345")
        expect(Rails.cache).to receive(:read)
        Cache.read('somekey').should eq '12345'
      end
      it 'should not touch the database' do
        expect(Cache).not_to receive(:write)
        expect(Cache).not_to receive(:create)
        expect(Cache).not_to receive(:save)
        Cache.read('somekey')
      end
    end
    context 'cache store got wiped but there is a table record' do
      before :each do
        Cache.clear
        Cache.create key: 'lostkey', value: '456'
        Rails.cache.clear
      end
      it 'writes the value back to the now online cache store' do
        Rails.cache.read('lostkey').should be_nil
        Cache.read('lostkey')
        Rails.cache.read('lostkey').should eq '456'
      end
    end
  end

  describe '#write' do
    before :each do
      Rails.cache.clear
      Cache.clear
    end

    it 'writes a value to both the cache store and the cache table' do
      Cache.write "testkey", "whoohoo"
      Rails.cache.read('testkey').should eq "whoohoo"
      Cache.find_by(key: "testkey").value.should eq "whoohoo"
    end

    it 'overwrites a value for an existing key in both the database and the cache store' do
      value1 = "12345678"
      value2 = "9875432"

      Cache.write 'existingkey', value1
      Cache.count.should eq 1
      record = Cache.find_by(key: 'existingkey')
      record.value.should eq value1
      Rails.cache.read('existingkey').should eq value1

      Cache.write 'existingkey', value2
      Cache.count.should eq 1
      record = Cache.find_by(key: 'existingkey')
      record.value.should eq value2
      Rails.cache.read('existingkey').should eq value2
    end

    it 'writes arrays' do
      test_array = ['one', 2, 'three', 4, 'five']
      Cache.write 'testarray', ['one', 2, 'three', 4, 'five']
      Cache.read('testarray').should eq test_array
    end
  end
end
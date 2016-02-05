require "spec_helper"

Rails.application.configure do
  config.cache_store = :null_store
end


describe Cache do
  describe '#read' do
    context "value exists in cache store" do
      before :each do
        Rails.cache.clear
        Rails.cache.write('somekey', '12345')
        Cache.clear
      end
      it 'returns the value from the cache store' do
        Cache.read('somekey').should eq '12345'
      end
      # it 'writes the value to a table record' do
      #   Cache.read('somekey').should eq '12345'
      #   Cache.where(key: 'somekey').first.value.should eq '12345'
      # end
    end
    context 'cache store got wiped but there is a table record' do
      before :each do
        Cache.clear
        Rails.cache.clear
        Cache.create key: 'lostkey', value: '456'
      end
      it 'writes the value back to the now online cache store' do
        Cache.read('lostkey')
        Rails.cache.read('lostkey').should eq '456'
      end
    end
  end
end
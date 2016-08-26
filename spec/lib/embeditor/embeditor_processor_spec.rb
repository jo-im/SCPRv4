require 'spec_helper'
require "#{Rails.root}/lib/embeditor/embeditor_processor"

describe Embeditor::Processor do
  describe '#process' do
    embeditor = nil
    after(:each) do
      embeditor.close
    end
    context 'normally' do
      it 'returns output' do
        embeditor = Embeditor::Processor.new(test: true)
        test_string = '<h1>hello world</h1>'
        output = embeditor.process(test_string)
        expect(output).to eq test_string
      end
    end
    context 'in response to an error' do
      it 'returns the original input' do
        embeditor = Embeditor::Processor.new(test: :error)
        test_string = '<h1>hello world</h1>'
        output = embeditor.process(test_string)
        expect(output).to eq test_string
      end
    end
    context 'with a hanging Node.js process' do
      embeditor = nil
      before(:each) do
        embeditor = Embeditor::Processor.new(test: :hang)
      end
      it 'returns the original input' do
        test_string = '<h1>hello world</h1>'
        output = embeditor.process(test_string)
        expect(output).to eq test_string
      end
    end
  end
  describe '#close' do
    it 'kills the process' do
      embeditor = Embeditor::Processor.new(test: true)
      embeditor.close
      expect(embeditor.closed?).to eq true
    end
  end
end
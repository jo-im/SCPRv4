require 'spec_helper'

describe Outpost::QuotesController do
  it_behaves_like "resource controller" do
    let(:resource) { [:quote, :published] }
  end
end

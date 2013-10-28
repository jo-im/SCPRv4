require "spec_helper"

describe Outpost::AbstractsController do
  it_behaves_like "resource controller" do
    let(:resource) { :abstract }
  end
end

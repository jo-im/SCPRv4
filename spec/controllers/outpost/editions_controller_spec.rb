require "spec_helper"

describe Outpost::EditionsController do
  it_behaves_like "resource controller" do
    let(:resource) { :edition }
  end
end

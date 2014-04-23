require "spec_helper"

describe Outpost::VerticalsController do
  it_behaves_like "resource controller" do
    let(:resource) { :vertical }
  end
end

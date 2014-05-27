require "spec_helper"

describe Outpost::TagsController do
  it_behaves_like "resource controller" do
    let(:resource) { :tag }
  end
end

require "spec_helper"

describe Outpost::IssuesController do
  it_behaves_like "resource controller" do
    let(:resource) { :issue }
  end
end

require "spec_helper"

describe Outpost::CategoriesController do
  it_behaves_like "resource controller" do
    let(:resource) { :category }
  end
end

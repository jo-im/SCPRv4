require "spec_helper"

describe Outpost::NewsStoriesController do
  it_behaves_like "resource controller" do
    let(:resource) { :news_story }
  end
end

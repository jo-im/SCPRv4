require "spec_helper"

describe Outpost::BreakingNewsAlertsController do
  it_behaves_like 'resource controller' do
    let(:resource) { :breaking_news_alert }
  end
end

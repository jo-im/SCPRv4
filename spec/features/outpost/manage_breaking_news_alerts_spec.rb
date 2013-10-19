require "spec_helper"

describe BreakingNewsAlert do
  let(:valid_record) { build :breaking_news_alert, headline: "It's hot outside!" }
  let(:invalid_record) { build :breaking_news_alert, headline: "" }
  let(:updated_record) { build :breaking_news_alert, headline: "It's raining!" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end

require "spec_helper"

describe BreakingNewsAlert do
  field_opts = { :field_options => { status: "status-select" } }

  let(:valid_record) { build :breaking_news_alert, headline: "It's hot outside!" }
  let(:invalid_record) { build :breaking_news_alert, headline: "" }
  let(:updated_record) { build :breaking_news_alert, headline: "It's raining!" }

  it_behaves_like "managed resource", field_opts
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model", field_opts
end

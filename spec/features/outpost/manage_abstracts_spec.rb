require "spec_helper"

describe Abstract do
  let(:valid_record) { build :abstract, url: "http://scpr.org" }
  let(:invalid_record) { build :abstract, source: "" }
  let(:updated_record) { build :abstract, url: "http://kpcc.org" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end

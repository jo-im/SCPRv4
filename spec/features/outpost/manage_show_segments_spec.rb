require "spec_helper"

describe ShowSegment do
  field_opts = { :field_options => { status: "status-select" } }

  let(:valid_record) { build :show_segment, :published }
  let(:updated_record) { build :show_segment, :published }
  let(:invalid_record) { build :show_segment, :published, headline: "" }

  it_behaves_like "managed resource", field_opts
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model", field_opts
  it_behaves_like "front-end routes"
end

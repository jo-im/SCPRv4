require "spec_helper"

describe Homepage do
  field_opts = { :field_options => { status: "status-select" } }

  let(:valid_record) { build :homepage, base: "default" }
  let(:invalid_record) { nil } # Can't make an invalid homepage in outpost.
  let(:updated_record) { build :homepage, base: "wide" }

  it_behaves_like "managed resource", field_opts
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model", field_opts
end

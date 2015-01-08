require "spec_helper"

describe Bio do
  let(:valid_record)   { build :bio }
  let(:updated_record) { build :bio }
  let(:invalid_record) { build :bio, name: "", title: "" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end

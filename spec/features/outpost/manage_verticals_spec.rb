require "spec_helper"

describe Vertical do
  let(:valid_record) { build :vertical }
  let(:updated_record) { build :vertical, title: "New Title" }
  let(:invalid_record) { build :vertical, slug: "" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
  it_behaves_like "front-end routes"
end

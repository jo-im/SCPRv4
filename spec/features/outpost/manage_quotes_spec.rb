require "spec_helper"

describe Quote do
  let(:valid_record) { build :quote, :published }
  let(:updated_record) { build :quote, :published }
  let(:invalid_record) { build :quote, :published, category_id: nil }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end


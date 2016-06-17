require "spec_helper"

describe FeaturedComment do
  let(:valid_record) { build :featured_comment }
  let(:updated_record) { build :featured_comment }
  let(:invalid_record) { build :featured_comment, username: "" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end

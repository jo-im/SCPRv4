require "spec_helper"

describe BlogEntry do
  let(:category) {create :category}
  let(:valid_record) { build :blog_entry, :published, category: category }
  let(:updated_record) { build :blog_entry, :published, category: category }
  let(:invalid_record) { build :blog_entry, :published, headline: "" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
  it_behaves_like "front-end routes"
end

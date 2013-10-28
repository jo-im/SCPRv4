require "spec_helper"

describe Edition do
  let(:valid_record) { build :edition, :unpublished }
  let(:invalid_record) { nil } # Can't make an invalid edition in outpost.
  let(:updated_record) { build :edition, :published }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end

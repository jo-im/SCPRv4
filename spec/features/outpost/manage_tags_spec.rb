require 'spec_helper'

describe Tag do
  let(:valid_record) { build :tag }
  let(:updated_record) { build :tag }
  let(:invalid_record) { build :tag, title: "" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end

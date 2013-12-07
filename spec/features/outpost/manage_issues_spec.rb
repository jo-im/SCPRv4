require 'spec_helper'

describe Issue do
  let(:valid_record) { build :issue, :is_active }
  let(:updated_record) { build :issue, :is_active }
  let(:invalid_record) { build :issue, :is_active, title: "" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
end

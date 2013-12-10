require "spec_helper"

describe ContentShell do
  field_opts = { :field_options => { status: "status-select" } }

  let(:valid_record) { build :content_shell, :published }
  let(:updated_record) { build :content_shell, :published }
  let(:invalid_record) { build :content_shell, :published, headline: "" }

  it_behaves_like "managed resource", field_opts
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model", field_opts
end

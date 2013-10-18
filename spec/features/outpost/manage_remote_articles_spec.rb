require "spec_helper"

describe RemoteArticle do
  let(:valid_record) { build :remote_article }
  let(:invalid_record) { nil }
  let(:updated_record) { build :remote_article }

  describe "Admin Paths" do
    before :each do
      login
      valid_record.save!
    end

    it "returns success when following admin_index_path" do
      visit valid_record.class.admin_index_path
      current_path.should eq valid_record.class.admin_index_path
    end
  end
end

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

  describe "managing the quote" do
    before do
      login
    end

    it "accepts nested quote fields" do
      vertical = create :vertical
      visit vertical.admin_edit_path

      find_field("vertical_quote_attributes_source_name").value.should be_blank
      fill_in "vertical_quote_attributes_source_name", with: "Bryan"
      fill_in "vertical_quote_attributes_source_context", with: "KPCC"
      fill_in "vertical_quote_attributes_text", with: "Cool Quote"

      click_button "edit"

      find_field("vertical_quote_attributes_source_name").value.should eq "Bryan"
      find_field("vertical_quote_attributes_source_context").value.should eq "KPCC"
      find_field("vertical_quote_attributes_text").value.should eq "Cool Quote"
    end

    it "is cleared out if the destroy checkbox is checked" do
      vertical = build :vertical
      quote    = build :quote, source_name: "Bryan"
      vertical.quote = quote
      vertical.save!
      visit vertical.admin_edit_path

      find_field("vertical_quote_attributes_source_name").value.should eq "Bryan"
      find_field("vertical_quote_attributes__destroy").set(true)
      click_button "edit"

      find_field("vertical_quote_attributes_source_name").value.should be_blank
    end

    it "is ignored if the fields are empty" do
      vertical = create :vertical
      visit vertical.admin_edit_path

      click_button "edit"

      find_field("vertical_quote_attributes_source_name").value.should be_blank
    end
  end
end

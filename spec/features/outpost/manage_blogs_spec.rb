require "spec_helper"

describe Blog do
  let(:valid_record) { build :blog }
  let(:updated_record) { build :blog }
  let(:invalid_record) { build :blog, name: "" }

  it_behaves_like "managed resource"
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model"
  it_behaves_like "front-end routes"

  # There was a bug where creating a new blog with the "Hosts" field filled
  # in would cause an error on BlogAuthor: "blog_id doesn't have a default
  # value".
  describe "creating with hosts on first save" do
    before :each do
      login
      @bio = create :bio
      visit Blog.admin_new_path
    end

    it "is created", focus: true do
      blog = build :blog
      blog.authors << @bio

      fill_required_fields(blog)
      fill_field blog, :author_ids

      click_button "edit"

      described_class.count.should eq 1
      valid = described_class.first
      current_path.should eq valid.admin_edit_path
      page.should have_css ".alert-success"
      page.should_not have_css ".alert-error"
      page.should_not have_css ".help-inline"
      page.should have_css "#edit_#{described_class.singular_route_key}_#{valid.id}"

      find("#blog_author_ids").value.should eq [@bio.id.to_s]
    end
  end
end

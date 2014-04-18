require "spec_helper"

describe AdminUser do
  let(:valid_record) { build :admin_user, name: "Bryan Ricker" }
  let(:invalid_record) { build :admin_user, name: "" }

  let(:updated_record) {
    build :admin_user, name: "Larry David", username: "ldavid"
  }

  it_behaves_like "save options"
  it_behaves_like "admin routes"

  # We have to copy these over because for admin user it's not exactly the
  # same. Specifically, the counts are off by 1 since we need a user to login
  # and stuff.
  describe 'managing resource' do
    before :each do
      login
      # Touch them so their associations get created
      valid_record
      invalid_record
      updated_record
    end

    #------------------------

    describe "Index" do
      before do
        # This is a hack so we know the valid_record object is the first
        # in the list.
        valid_record.update_attribute(:name, "aaaaaaa")
      end

      it "shows a list of records" do
        visit described_class.admin_index_path

        within('table.index-list') do
          page.should have_css "a.btn"
          first('a.btn').click

          current_path.should eq valid_record.admin_edit_path
        end
      end
    end

    describe "Create" do
      before :each do
        visit described_class.admin_new_path
      end

      context "invalid" do
        it "shows validation errors" do
          fill_required_fields(invalid_record)
          click_button "edit"
          current_path.should eq described_class.admin_index_path
          described_class.count.should eq 1
          page.should_not have_css ".alert-success"
          page.should have_css ".alert-error"
          page.should have_css ".help-inline"
        end
      end

      context "valid" do
        it "is created" do
          fill_required_fields(valid_record)
          click_button "edit"
          described_class.count.should eq 2
          valid = described_class.last
          current_path.should eq valid.admin_edit_path
          page.should have_css ".alert-success"
          page.should_not have_css ".alert-error"
          page.should_not have_css ".help-inline"
          page.should have_css "#edit_#{described_class.singular_route_key}_#{valid.id}"
        end
      end
    end

    describe "Update" do
      before :each do
        valid_record.save!
        visit valid_record.admin_edit_path
      end

      context "invalid" do
        it "shows validation error" do
          fill_required_fields(invalid_record)
          click_button "edit"
          page.should have_css ".alert-error"
          current_path.should eq valid_record.admin_show_path # Technically "#update" but this'll do
        end
      end

      context "valid" do
        it "updates attributes" do
          fill_required_fields(updated_record)
          click_button "edit"
          page.should have_css ".alert-success"
          current_path.should eq valid_record.admin_edit_path
        end
      end
    end

    describe "Destroy" do
      before :each do
        valid_record.save!
        visit valid_record.admin_edit_path
      end

      it "Deletes the record and redirects to index" do
        click_link "Delete"
        current_path.should eq described_class.admin_index_path
        page.should have_css ".alert-success"
        described_class.count.should eq 1 # user for feature specs
      end
    end
  end

  describe "Save options" do
    before :each do
      login
      valid_record.save!
      visit valid_record.admin_edit_path
    end

    context "Save" do
      it "returns to the edit page" do
        click_button "edit"
        current_path.should eq valid_record.admin_edit_path
        page.should have_css ".alert-success"
        page.should have_css "form#edit_#{described_class.singular_route_key}_#{valid_record.id}"
      end
    end

    context "Save & Return to List" do
      it "returns to the index page" do
        click_button "index"
        current_path.should eq described_class.admin_index_path
        page.should have_css ".alert-success"
        page.should have_css ".index-header"
      end
    end

    context "Save & Add Another" do
      it "returns to the new page" do
        click_button "new"
        page.should have_css ".alert-success"
        current_path.should eq described_class.admin_new_path
      end
    end
  end


  describe "Versions" do
    before :each do
      login
      @user.update_attribute(:is_superuser, true)

      # touch records to created associated objects
      valid_record
      updated_record
    end

    context "new record" do
      it "saves an initial version" do
        visit described_class.admin_new_path
        fill_required_fields(valid_record)
        click_button "edit"
        described_class.count.should eq 2
        new_record = described_class.last
        new_record.versions.size.should eq 1
        click_link "history"
        page.should have_content "Created #{described_class.name.demodulize.titleize} ##{new_record.id}"
      end
    end

    context "existing record" do
      it "saves a new version" do
        valid_record.save!
        visit valid_record.admin_edit_path
        fill_required_fields(updated_record)
        click_button "edit"
        updated = described_class.find(valid_record.id)
        updated.versions.size.should eq 2
        click_link "history"
        current_path.should eq outpost_history_path(valid_record.class.route_key, valid_record.id)
        page.should have_content "View"
        first(:link, "View").click # Capybara 2.0 throws error for ambigious match.
      end
    end
  end
end

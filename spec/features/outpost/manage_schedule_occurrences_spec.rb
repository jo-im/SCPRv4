require "spec_helper"

describe ScheduleOccurrence do
  let(:valid_record) { build :schedule_occurrence, info_url: "http://scpr.org" }
  let(:invalid_record) { build :schedule_occurrence, info_url: "notvalid.com" }
  let(:updated_record) { build :schedule_occurrence, info_url: "http://kpcc.org" }

  it_behaves_like "managed resource index"
  it_behaves_like "managed resource destroy"
  it_behaves_like "save options"
  it_behaves_like "admin routes"

  # We need to copy these because info_url isn't officially validated,
  # so `fill_required_fields` doesn't work.

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
        fill_in "schedule_occurrence_event_title", with: valid_record.event_title
        fill_in "schedule_occurrence_info_url", with: valid_record.info_url
        click_button "edit"
        described_class.count.should eq 1
        new_record = described_class.first
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
        fill_in "schedule_occurrence_event_title", with: updated_record.event_title
        fill_in "schedule_occurrence_info_url", with: updated_record.info_url
        click_button "edit"
        updated = described_class.find(valid_record.id)
        updated.versions.size.should eq 2
        click_link "history"
        current_path.should eq secretary.history_path(valid_record.class.route_key, valid_record.id)
        page.should have_content "View"
        first(:link, "View").click # Capybara 2.0 throws error for ambigious match.
      end
    end
  end


  describe "managing resource" do
    before :each do
      login
      # Touch them so their associations get created
      valid_record
      invalid_record
      updated_record
    end

    describe "Create" do
      before :each do
        visit described_class.admin_new_path
      end

      context "invalid" do
        it "shows validation errors" do
          if invalid_record
            fill_required_fields(invalid_record)
            fill_in "schedule_occurrence_info_url", with: invalid_record.info_url
            click_button "edit"
            current_path.should eq described_class.admin_index_path
            described_class.count.should eq 0
            page.should_not have_css ".alert-success"
            page.should have_css ".alert-error"
            page.should have_css ".help-inline"
          end
        end
      end

      context "valid" do
        it "is created" do
          fill_required_fields(valid_record)
          fill_in "schedule_occurrence_event_title", with: valid_record.event_title
          fill_in "schedule_occurrence_info_url", with: valid_record.info_url
          click_button "edit"
          described_class.count.should eq 1
          valid = described_class.first
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
          if invalid_record
            fill_required_fields(invalid_record)
            fill_in "schedule_occurrence_info_url", with: invalid_record.info_url
            click_button "edit"
            page.should have_css ".alert-error"
            current_path.should eq valid_record.admin_show_path # Technically "#update" but this'll do
          end
        end
      end

      context "valid" do
        it "updates attributes" do
          fill_required_fields(updated_record)
          fill_in "schedule_occurrence_event_title", with: updated_record.event_title
          fill_in "schedule_occurrence_info_url", with: updated_record.info_url
          click_button "edit"
          page.should have_css ".alert-success"
          current_path.should eq valid_record.admin_edit_path
        end
      end
    end
  end
end

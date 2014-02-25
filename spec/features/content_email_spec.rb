require 'spec_helper'

describe "E-mailing content" do

  describe 'for a valid obj_key' do
    it "shows the form" do
      entry = create :blog_entry

      visit content_email_path(obj_key: entry.obj_key)
      page.should have_content "Email this to a friend"
    end
  end

  describe 'for an invalid obj_key' do
    it "shows an error" do
      admin_user = create :admin_user

      -> {
        visit content_email_path(obj_key: admin_user.obj_key)
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'valid data' do
    before do
      @entry = create :blog_entry
    end

    it "shows a success message" do
      visit content_email_path(obj_key: @entry.obj_key)
      fill_in 'content_email_to_email', with: "bricker@scpr.org"
      fill_in 'content_email_from_email', with: "bricker@scpr.org"
      click_button 'Share'

      page.should have_content "successfully shared"
    end
  end

  describe 'invalid data' do
    before do
      @entry = create :blog_entry
    end

    it "shows a validation error message" do
      visit content_email_path(obj_key: @entry.obj_key)
      fill_in 'content_email_to_email', with: ""
      fill_in 'content_email_from_email', with: ""
      click_button 'Share'

      page.should have_content "can't be blank"
    end
  end
end

require "spec_helper"

describe ShowEpisode do
  field_opts = { :field_options => { status: "status-select" } }

  let(:valid_record) { build :show_episode, :published }
  let(:updated_record) { build :show_episode, :published }
  let(:invalid_record) { build :show_episode, :published, teaser: "" }

  it_behaves_like "managed resource", field_opts
  it_behaves_like "save options"
  it_behaves_like "admin routes"
  it_behaves_like "versioned model", field_opts
  it_behaves_like "front-end routes"

  describe "podcast ad placement" do
    before :each do
      login

      @on_air_program = create :kpcc_program, air_status: "onair"
      @show_episode = create :show_episode, show: @on_air_program

      $megaphone = MegaphoneClient.new({
        token: "STUB_TOKEN"
      })
    end

    it "is visible when the program is on air" do
      visit @show_episode.admin_edit_path
      expect(page).to have_selector('#form-block-podcast-ad-placement')
    end

    it "is hidden when the program is off air" do
      kpcc_program = create :kpcc_program, air_status: "hidden"
      show_episode = create :show_episode, show: kpcc_program
      visit show_episode.admin_edit_path
      expect(page).not_to have_selector('#form-block-podcast-ad-placement')
    end

    it "fields are enabled if the podcast record is available" do
      visit @show_episode.admin_edit_path
      expect(page).not_to have_css('#show_episode_pre_count[disabled]')
      expect(page).not_to have_css('#show_episode_post_count[disabled]')
      expect(page).not_to have_css('#show_episode_insertion_points[disabled]')
    end

    it "fields are disabled if the podcast record is not available" do
      # Intentionally throw an error to trigger an empty response
      $megaphone = MegaphoneClient.new({
        token: "INCORRECT_TOKEN"
      })
      visit @show_episode.admin_edit_path
      expect(page).to have_css('#show_episode_pre_count[disabled]')
      expect(page).to have_css('#show_episode_post_count[disabled]')
      expect(page).to have_css('#show_episode_insertion_points[disabled]')
    end

    it "is populated with data if the podcast record already exists" do
      visit @show_episode.admin_edit_path
      pre_count = find_field('show_episode[pre_count]').value
      post_count = find_field('show_episode[post_count]').value
      insertion_points = find_field('show_episode[insertion_points]').value
      expect(pre_count).to eq "1"
      expect(post_count).to eq "2"
      expect(insertion_points).to eq "3.0"
    end

    it "only sends a PUT request if new values are different than the old ones" do
      visit @show_episode.admin_edit_path
      fill_in('show_episode[pre_count]', with: 5)
      fill_in('show_episode[post_count]', with: 5)
      click_button('commit_action')
    end

    it "rescues api calls if something is wrong" do
      # Intentionally throw an error to trigger an empty response
      $megaphone = MegaphoneClient.new({
        token: "INCORRECT_TOKEN"
      })

      expect { visit @show_episode.admin_edit_path }.not_to raise_error
    end
  end
end

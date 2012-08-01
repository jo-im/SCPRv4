require "spec_helper"

describe HomeController do
  describe "POST /process_archive_select" do
    it "redirects to archive_path with the processed date" do
      post :process_archive_select, 
        archive: { "date(1i)" => "2012", "date(2i)" => "4", "date(3i)" => "1" }
      response.should redirect_to archive_path("2012", "04", "01")
    end
  end
  
  describe "archive" do
    it "doesn't assign date if none requested" do
      get :archive
      assigns(:date).should be_nil
    end
    
    it "assigns date to requested date" do
      get :archive, date_path(Time.now.yesterday.beginning_of_day)
      assigns(:date).should eq Time.now.yesterday.beginning_of_day
    end
    
    it "date is a Time object" do
      get :archive, date_path(Time.now.yesterday.beginning_of_day)
      assigns(:date).should be_a Time
    end
    
    %w{ news_story show_segment blog_entry video_shell content_shell }.each do |content|
      it "only gets #{content.pluralize} published on requested date" do
        yesterday = create content.to_sym, published_at: Time.now.yesterday
        today     = create content.to_sym, published_at: Time.now
        tomorrow  = create content.to_sym, published_at: Time.now.tomorrow
        get :archive, date_path(Time.now.yesterday)
        assigns(content.pluralize.to_sym).should eq [yesterday]
      end
    end
    
    it "only gets show episodes published on requested date" do
      yesterday = create :show_episode, air_date: Time.now.yesterday.strftime("%Y/%m/%d")
      today     = create :show_episode, air_date: Time.now.strftime("%Y/%m/%d")
      tomorrow  = create :show_episode, air_date: Time.now.tomorrow.strftime("%Y/%m/%d")
      get :archive, date_path(Time.now.yesterday.beginning_of_day)
      assigns(:show_episodes).should eq [yesterday]
    end
  end
end

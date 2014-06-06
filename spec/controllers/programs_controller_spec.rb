require "spec_helper"

describe ProgramsController do
  describe "GET /archive" do
    it "finds the episode for the program on the given date" do
      episode = create :show_episode, air_date: Time.new(2012, 3, 22)
      post :archive,
        :show    => episode.show.slug,
        :archive => {
          "date(1i)" => episode.air_date.year,
          "date(2i)" => episode.air_date.month,
          "date(3i)" => episode.air_date.day
        }

      assigns(:episode).should eq episode
    end

    it "assigns @date if date is given" do
      episode = create :show_episode, air_date: Time.new(2012, 3, 22)
      post :archive,
        :show    => episode.show.slug,
        :archive => {
          "date(1i)" => episode.air_date.year,
          "date(2i)" => episode.air_date.month,
          "date(3i)" => episode.air_date.day
        }

      date = assigns(:date)
      date.should be_a Time
      date.beginning_of_day.should eq episode.air_date.beginning_of_day
    end

    it "works for external programs" do
      episode = create :external_episode, air_date: Time.new(2012, 3, 22)

      post :archive, show: episode.external_program.slug,
        :archive => {
          "date(1i)" => episode.air_date.year,
          "date(2i)" => episode.air_date.month,
          "date(3i)" => episode.air_date.day
        }

      assigns(:episode).should eq episode
    end
  end


  describe "GET /schedule" do
    it "assigns @schedule_occurrences to this week's schedule" do
      create :schedule_occurrence,
        starts_at: Time.now.beginning_of_week
      create :schedule_occurrence,
        starts_at: Time.now.beginning_of_week + 1.day
      create :schedule_occurrence,
        starts_at: Time.now.beginning_of_week + 2.days

      get :schedule
      assigns(:schedule_occurrences).should eq ScheduleOccurrence.all
    end
  end


  describe "GET /index" do
    it "assigns @kpcc_programs to active ordered by title" do
      active = create :kpcc_program, air_status: "onair"
      inactive = create :kpcc_program, air_status: "hidden"

      get :index
      assigns(:kpcc_programs).to_sql.should match /order by title/i
      assigns(:kpcc_programs).should eq [active]
    end

    it "assigns @external_programs to active ordered by title" do
      active = create :external_program, :from_rss, air_status: "onair"
      inactive = create :external_program, :from_rss, air_status: "hidden"

      get :index
      assigns(:external_programs).to_sql.should match /order by title/i
      assigns(:external_programs).should eq [active]
    end
  end


  describe "GET /show" do
    context "KPCC Program" do
      before do
        @program = create :kpcc_program, display_episodes: false
      end

      it "sets @program" do
        get :show, show: @program.slug
        assigns(:program).should eq @program
      end

      it "assigns @segments to published segments" do
        published = create_list :show_segment, 2, :published, show: @program
        unpublished = create_list :show_segment, 2, :draft, show: @program

        get :show, show: @program.slug
        assigns(:segments).sort.should eq published.sort
      end

      it "assigns @episodes to published episodes" do
        published = create_list :show_episode, 2, :published, show: @program
        unpublished = create_list :show_episode, 2, :draft, show: @program

        get :show, show: @program.slug
        assigns(:episodes).sort.should eq published.sort
      end

      context "html" do
        it "excludes current episode and its segments from @episodes" do
          @program.update_column(:display_episodes, true)

          episode = build :show_episode, :published,
            :show => @program,
            :air_date => 1.hour.ago

          segment = create :show_segment, :published, show: @program
          episode.segments << segment
          episode.save!

          other_episode = create :show_episode, :published,
            :show => @program,
            :air_date => 1.day.ago

          get :show, show: @program.slug

          assigns(:episodes).should_not include episode
          assigns(:segments).should_not include segment
          assigns(:current_episode).should eq episode
        end

        it "renders the correct kpcc template" do
          get :show, show: @program.slug
          response.should render_template "programs/kpcc/show"
        end
      end

      context "xml" do
        it "renders xml template" do
          get :show, show: @program.slug, format: :xml
          response.should render_template 'programs/kpcc/show'
          response.header['Content-Type'].should match /xml/
        end
      end
    end

    context "External Program" do
      before do
        @program = create :external_program
      end

      it "sets @episodes to the program's episodes" do
        episode = create :external_episode, external_program: @program
        get :show, show: @program.slug
        assigns(:episodes).to_a.should eq [episode]
      end

      context "html" do
        it "renders the correct external template" do
          get :show, show: @program.slug
          response.should render_template "programs/external/show"
        end
      end

      context "xml" do
        it "redirects to the podcast URL" do
          program = create :external_program, :from_rss
          get :show, show: program.slug, format: :xml
          response.should redirect_to program.podcast_url
        end
      end
    end
  end


  describe "GET /segment" do
    describe "for invalid segment" do
      it "raises error for invalid id" do
        segment = create :show_segment
        -> {
          get :segment, {
            :show   => segment.show.slug,
            :id     => "9999999",
            :slug   => segment.slug
          }.merge!(date_path(segment.published_at))

        }.should raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "for valid segment" do
      it "assigns @segment" do
        segment = create :show_segment
        get :segment, segment.route_hash
        assigns(:segment).should eq segment
      end
    end
  end


  describe "GET /episode" do
    let(:program) { create :kpcc_program }
    let(:episode) { create :show_episode, show: program }
    let(:segment) { create :show_segment }

    let(:params) do
      episode.route_hash
    end

    it "raises an error if the episode isn't found" do
      -> {
        get :episode, params.merge(id: 999)
      }.should raise_error ActiveRecord::RecordNotFound
    end

    it "gets the requested episode" do
      get :episode, params
      assigns(:episode).should eq episode
    end

    it "gets the episode's segments" do
      episode.rundowns.create(segment: segment)
      get :episode, params

      assigns(:segments).to_a.should eq [segment]
    end
  end
end

require "spec_helper"

describe ProgramsController do
  render_views

  describe "GET /archive" do
    it "finds the episode for the program on the given date" do
      episode = create :show_episode, air_date: Time.zone.local(2012, 3, 22)
      post :archive,
        :show    => episode.show.slug,
        :archive => {
          "date(1i)" => episode.air_date.year,
          "date(2i)" => episode.air_date.month,
          "date(3i)" => episode.air_date.day
        }

      assigns(:episode).should eq episode
      expect(response).to redirect_to episode.public_path
    end

    it "assigns @date if date is given" do
      episode = create :show_episode, air_date: Time.zone.local(2012, 3, 22)
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
      episode = create :external_episode, air_date: Time.zone.local(2012, 3, 22)

      post :archive, show: episode.program.slug,
        :archive => {
          "date(1i)" => episode.air_date.year,
          "date(2i)" => episode.air_date.month,
          "date(3i)" => episode.air_date.day
        }

      assigns(:episode).should eq episode
    end

    it "finds no episode" do
      program = create :kpcc_program
      post :archive,
        show: program.slug,
        archive: {
          "date(1i)" => "2001",
          "date(2i)" => "1",
          "date(3i)" => "1"
        }
      assigns(:episode).should eq nil
      expect(response).to redirect_to list_path(program.slug, anchor: "archive")
    end
  end


  describe "GET /schedule" do
    it "assigns @schedule_occurrences to today's schedule by default" do
      create :schedule_occurrence,
        starts_at: Time.zone.now.beginning_of_day
      create :schedule_occurrence,
        starts_at: Time.zone.now.beginning_of_week + 1.day
      create :schedule_occurrence,
        starts_at: Time.zone.now.beginning_of_week + 2.days

      get :schedule
      assigns(:schedule_occurrences).should eq ScheduleOccurrence.block(Time.zone.now.beginning_of_day, 1.day, true)
    end

    it "assigns @schedule_occurrences based off of query parameters that indicate a date" do
      create :schedule_occurrence,
      starts_at: Time.zone.local(2017, 8, 16)
      create :schedule_occurrence,
      starts_at: Time.zone.now.beginning_of_week + 1.day
      create :schedule_occurrence,
      starts_at: Time.zone.now.beginning_of_week + 2.days

      get :schedule, { year: "2017", month: "08", day: "16" }
      assigns(:schedule_occurrences).should eq ScheduleOccurrence.block(Time.zone.local(2017, 8, 16), 1.day, true)
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
        @program = create :kpcc_program, is_segmented: false
      end

      it "sets @program" do
        get :show, show: @program.slug
        assigns(:program).should eq @program
      end

      it "assigns @current_episode to the latest episode" do
        published1 = create :show_episode, :published, show: @program, air_date: 1.day.ago
        published2 = create :show_episode, :published, show: @program, air_date: 1.week.ago

        get :show, show: @program.slug
        assigns(:current_episode).should eq published1
      end

      # it "assigns @episodes to published episodes except the current one" do
      #   published1 = create :show_episode, :published, show: @program, air_date: 1.day.ago
      #   published2 = create :show_episode, :published, show: @program, air_date: 1.week.ago
      #   unpublished = create_list :show_episode, 2, :draft, show: @program
      #
      #   get :show, show: @program.slug
      #   assigns(:episodes).should eq [published2]
      # end

      context "html" do
        # it "excludes current episode and its segments from @episodes" do
        #   @program.update_column(:is_segmented, true)
        #
        #   episode = build :show_episode, :published,
        #     :show => @program,
        #     :air_date => 1.hour.ago
        #
        #   segment = create :show_segment, :published, show: @program
        #   episode.save!
        #   episode.segments << segment
        #
        #   other_episode = create :show_episode, :published,
        #     :show => @program,
        #     :air_date => 1.day.ago
        #
        #   get :show, show: @program.slug
        #
        #   assigns(:episodes).should_not include episode
        #   assigns(:current_episode).should eq episode
        # end

        it "renders the correct kpcc template" do
          get :show, show: @program.slug
          response.should render_template "programs/standard_program"
        end
      end

      context "xml" do
        it "renders xml template" do
          get :show, show: @program.slug, format: :xml
          response.should render_template 'programs/show'
          response.header['Content-Type'].should match /xml/
        end

        it "renders segments for segmented programs" do
          program = create :kpcc_program, is_segmented: true
          segment = create :show_segment, :published, show: program, headline: "--Helloxx"
          get :show, show: program.slug, format: :xml

          response.body.should match "--Helloxx"
        end

        # it "renders episodes for non-segmented programs" do
        #   program = create :kpcc_program, is_segmented: false
        #   episode = create :show_episode, :published, show: program, headline: "--Helloxx"
        #   get :show, show: program.slug, format: :xml
        #
        #   response.body.should match "--Helloxx"
        # end
      end
    end

    context "External Program" do
      before do
        @program = create :external_program
      end

      # it "sets @episodes to the program's episodes" do
      #   episode = create :external_episode, program: @program
      #   get :show, show: @program.slug
      #   assigns(:episodes).to_a.should eq [episode]
      # end

      context "html" do
        it "renders the correct external template" do
          get :show, show: @program.slug
          response.should render_template "programs/standard_program"
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

    describe "public path" do
      context "the request path matches the public path" do
        it "renders the correct layout" do
          segment = create :show_segment
          get :segment, segment.route_hash
          expect(response).to render_template 'programs/kpcc/segment'
        end
      end
      context "the request path does not match the public path for" do
        it "redirect to the public path" do
          segment = create :show_segment
          route_hash = segment.route_hash
          route_hash[:show] = "show-x"
          get :segment, route_hash
          expect(response).to redirect_to segment.public_path
        end
      end
    end
  end


  describe "GET /episode" do
    let(:program) { create :kpcc_program }
    let(:episode) { create :show_episode, show: program }
    let(:segment) { create :show_segment, :published, show: program }

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

    # it "gets the episode's content" do
    #   episode.rundowns.create(content: segment)
    #   get :episode, params
    #   assigns(:content).to_a.should eq [segment.to_article]
    # end
  end

  describe "GET /featured_program" do
    context "KPCC Program" do
      before do
        @program = create :kpcc_program, slug: 'the-frame'
        @episodes = create_list :show_episode, 2, :published, show: @program
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

      # it "assigns @episodes to published episodes" do
      #   unpublished = create_list :show_episode, 2, :draft, show: @program
      #   get :show, show: @program.slug
      #   assigns(:episodes).should eq @episodes.sort! {|a,b| b[:air_date] <=> a[:air_date] }[1..-1]
      # end

      # context "a single featured episode is present" do
      #   it "excludes the latest episode from @episodes" do
      #     featured_episode = create :show_episode, :published,
      #       :show => @program,
      #       :air_date => 1.hour.ago
      #     @program.program_articles.create(article: featured_episode)
      #     @program.save!
      #
      #     get :show, show: @program.slug
      #
      #     assigns(:episodes).should_not include ShowEpisode.published.first
      #   end
      # end
    end
  end
end

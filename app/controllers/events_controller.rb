class EventsController < ApplicationController

  def index
    @scoped_events = Event.upcoming_and_current

    if params[:list] == "kpcc-in-person" || params[:list] == "forum"
      @scoped_events = @scoped_events.kpcc_in_person
    elsif params[:list] == "sponsored"
      @scoped_events = @scoped_events.sponsored
    end

    @events = Kaminari.paginate_array(Event.sorted(@scoped_events)).page(params[:page]).per(10)
  end

  def archive
    @events = Event.kpcc_in_person.past.page(params[:page]).per(10)
    @past_events = Event.kpcc_in_person.past.limit(5)
    @landing_page = LandingPage.find_by(title: 'KPCC In Person')
  end

  def show
    if params[:id]
      @event = Event.published.find(params[:id])
    else
      date    = Time.zone.local(params[:year], params[:month], params[:day])
      @event  = Event.published.where(
        :slug         => params[:slug],
        :starts_at    => date..date.end_of_day
      ).first!

      redirect_to @event.public_path and return
    end

    @more_events = Event.kpcc_in_person.upcoming.where("id != ?", @event.id).limit(2)
    @past_events     = Event.kpcc_in_person.past.limit(5)
    @landing_page = LandingPage.find_by(title: 'KPCC In Person')
  end

  def kpcc_in_person
    # Instance variables that pull featured events and biographies from the relevant landing page.
    # Fow now, it's set to find the correct landing page by title.
    @landing_page = LandingPage.find_by(title: 'KPCC In Person')
    @featured_events = @landing_page.try(:landing_page_contents).try(:map) {|a| a.article } || Event.kpcc_in_person.upcoming_and_current.limit(3)
    @team = @landing_page.try(:landing_page_reporters).try(:includes, :bio).try(:map) {|a| a.bio }

    # Set the default page to 1 for all tabs
    @subtype_param = params[:subtype]
    page_param = params[:page]
    upcoming_page = 1
    kpcc_in_person_page = 1
    sponsored_page = 1

    # Controls which tab the :page parameter is applied to
    if @subtype_param == 'list'
      kpcc_in_person_page = page_param
    elsif @subtype_param == 'sponsored'
      sponsored_page = page_param
    elsif @subtype_param == 'upcoming' || @subtype_param == nil
      upcoming_page = page_param
    end

    # Instance variable for three tabs
    @all_upcoming_events = Event.published.upcoming_and_current.page(upcoming_page).per(10)
    @kpcc_in_person_events = Event.kpcc_in_person.upcoming_and_current.page(kpcc_in_person_page).per(10)
    @sponsored_events = Event.sponsored.upcoming_and_current.page(sponsored_page).per(10)

    # Instance variable that populates the "Recent Events" side bar
    @past_events     = Event.kpcc_in_person.past.limit(5)
  end
end

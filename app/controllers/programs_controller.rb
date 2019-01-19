# This controller is annoying. The problem is that we have two different
# resources: KpccProgram, ExternalProgram, but they share the same URL
# namespace, so we have to send all traffic to this controller and then
# basically split every action into two.
class ProgramsController < ApplicationController
  include FlatpageHandler
  include Concern::Controller::GetPopularArticles
  include Concern::Controller::ShowEpisodes
  include Concern::Controller::Amp

  before_filter :get_program, only: [:show, :episode, :archive, :featured_program, :list]

  respond_to :html, :xml, :rss


  def index
    @featured_programs = (KpccProgram.where(is_featured: true) + ExternalProgram.where(is_featured: true)).try(:sort_by!) { |program| program.title }
    @kpcc_programs     = KpccProgram.active.order("title")
    @external_programs = ExternalProgram.active.order("title")
  end

  def show
    @segments = @program.segments.published.includes(:audio)
    @episodes = @program.episodes.published
    @featured_programs = KpccProgram.where.not(id: @program.id, is_featured: false)
    if @program.try(:featured_articles).try(:present?)
      if @program.featured_articles.size > 1
        @featured_story = @program.featured_articles.first
        @suggested_story = @program.featured_articles.first(2)[1]
        @episodes = @episodes.where.not(id: [@featured_story.original_object.id, @episodes.first.id])
        if @featured_story.original_object.is_a?(ShowSegment)
          @segments = @segments - [@featured_story.original_object]
        end
      else
        @featured_story = @episodes.first
        @suggested_story = @program.featured_articles.first
        @episodes = @episodes.where.not(id: @episodes.try(:first).try(:id))
      end
    else
      @featured_story = @episodes.first
      @suggested_story = @episodes.second
      @episodes = @episodes.where.not(id: @episodes.try(:first).try(:id))
    end
    @featured_story_article  = @featured_story.try(:get_article)
    @suggested_story_article = @suggested_story.try(:get_article)
    respond_to do |format|
      format.html do
        @current_episode = @featured_story

        if @program.is_a?(KpccProgram) && @program.try(:is_featured?) && @program.try(:is_segmented?)
          @episodes = (@current_episode ? @episodes.where.not(id:@current_episode.id) : @episodes).page(params[:page]).per(6)
          render
        else
          @collection = @program.episodes.published.page(params[:page]).per(6)
          render 'standard_program'
        end
      end
      format.xml do
        if @program.is_a?(KpccProgram)
          render
        else
          redirect_to @program.podcast_url
        end
      end
    end
  end

  def list
    if @program.is_a?(KpccProgram) && @program.is_featured?
      @view_type = params[:view]
      @segments = @program.segments.published
      @episodes = @program.episodes.published

      respond_with do |format|
        format.html do
          if @current_episode = @episodes.first
            @episodes = @episodes.where.not(id: @current_episode.id)

            segments = @current_episode.segments.published.to_a
            @segments = @segments.where.not(id: segments.map(&:id))
          end

          @segments = @segments.page(params[:page]).per(10)
          @episodes = @episodes.page(params[:page]).per(6)
          if @view_type == "episodes" || @view_type.blank?
            @collection = @episodes
          else
            @collection = @segments
          end
          render 'standard_program'
        end

        format.xml { render 'programs/kpcc/old/show' }
      end

      return
    else
      if @program.public_path
        redirect_to @program.public_path
      else
        redirect_to program_url(@program.slug)
      end
    end
  end

  def segment
    @segment = ShowSegment.published.includes(:show).find(params[:id])
    @episode = @segment.episode
    @program = @kpcc_program = @segment.show
    @featured_programs = KpccProgram.where.not(id: @program.id, is_featured: false).first(4)
    @url = request.original_url

    @is_pledge_time = PledgeDrive.happening?
    program_flatpage = Flatpage.visible.find_by path: 'exit-modal/' + @program.slug
    default_flatpage = Flatpage.visible.find_by path: 'exit-modal/default'
    pledge_flatpage = Flatpage.visible.find_by path: 'exit-modal/pledge'

    if @is_pledge_time && pledge_flatpage
      @modal = pledge_flatpage
      @google_analytics_label = 'Modal Type: Pledge Drive | URL: ' + @url
    elsif program_flatpage
      @modal = program_flatpage
      @google_analytics_label = 'Modal Type: ' + @modal.title + ' | URL: ' + @url
    elsif default_flatpage
      @modal = default_flatpage
      @google_analytics_label = 'Modal Type: ' + @modal.title + ' | URL: ' + @url
    end

    # check whether this is the correct URL for the segment
    if request.original_fullpath != @segment.public_path
      redirect_to @segment.public_path and return
    end

    render 'programs/kpcc/segment' and return
  end

  amplify :segment, expose: {'@amp_record' => "@segment"}, template: "amp/segment"

  def episode
    if @program.is_a?(KpccProgram)
      @amp_enabled = true
      @amp_record = @episode = @program.episodes.find(params[:id])
      # The #amplify method can't be used here because of the unusual way that this
      # action is written.  Another good reason to refactor this cludgy controller.
      return render(layout: "application.amp.erb", template: "amp/segment") if params.has_key?(:amp)

      if @program.is_featured?
        render_kpcc_episode
      else
        render_standard_episode
      end
    end

    if @program.is_a?(ExternalProgram)
      @episode  = @program.episodes.find(params[:id])
      render_external_episode
    end
  end

  def archive
    @date = Time.zone.local(
      params[:archive]["date(1i)"].to_i,
      params[:archive]["date(2i)"].to_i,
      params[:archive]["date(3i)"].to_i
    )
    @episode = @program.episodes.for_air_date(@date).published.first

    if !@episode
      flash[:alert] = "There is no #{@program.title} " \
                      "episode for #{@date.strftime('%F')}."
      redirect_to list_path(@program.slug, anchor: "archive")
    else
      redirect_to @episode.public_path
    end
  end

  def schedule
    @date = Time.zone.now.beginning_of_day

    if valid_date_from_params?
      @date = Time.zone.local(
        params[:year].to_i,
        params[:month].to_i,
        params[:day].to_i
      )
    end

    @schedule_occurrences = ScheduleOccurrence.block(@date, 1.day, true)
    # We can't cache all of them together, since there are too many.
    # So we'll just use the most recently updated one to cache.
    @cache_object = @schedule_occurrences.sort_by(&:updated_at).last
    render layout: "application"
  end


  private

  def get_program
    @program = KpccProgram.find_by_slug(params[:show]) ||
      ExternalProgram.find_by_slug(params[:show])

    # Check if there's a flatpage first before routing to the program page
    path = "programs/#{params[:show]}"
    if @flatpage = Flatpage.visible.find_by_path(path.downcase)
      handle_flatpage and return
    end

    if !@program
      render_error(404, ActionController::RoutingError.new("Not Found"))
      return false
    end
  end

  def valid_date_from_params?
    year = params[:year]
    month = params[:month]
    day = params[:day]
    date_string = "#{year}-#{month}-#{day}"

    begin
       Date.parse(date_string)
    rescue ArgumentError
       # handle invalid date
       return false
    end

    return true
  end

end

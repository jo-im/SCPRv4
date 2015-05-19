module Api::Public::V3
  class EpisodesController < BaseController

    before_filter \
      :sanitize_program_slug,
      :sanitize_air_date,
      :sanitize_page,
      :sanitize_limit,
      only: [:index, :archive]

    before_filter :sanitize_id, only: [:show]

    DEFAULTS = {
      :limit => 4,
      :page  => 1
    }

    MAX_RESULTS = 8

    #---------------------------

    def index
      if @program
        @episodes = @program.episodes
      else
        @episodes = ShowEpisode.published
      end

      if @air_date
        @episodes = @episodes.for_air_date(@air_date)
      end

      @episodes = @episodes.page(@page).per(@limit).map(&:to_episode)
      respond_with @episodes
    end

    #---------------------------

    def show
      @episode = ShowEpisode.published.where(id: @id).first

      if !@episode
        render_not_found and return false
      end

      @episode = @episode.to_episode
      respond_with @episode
    end

    #---------------------------

    def archive
      date = Time.parse("#{params[:year]}-#{params[:month]}-01")
      @episodes = @program.episodes.published.where(air_date: date.beginning_of_month..date.end_of_month)
      respond_with @episodes
    end

    private

    def sanitize_air_date
      if params[:air_date]
        begin
          @air_date = Time.zone.parse!(params[:air_date])
        rescue ArgumentError # Time couldn't be parsed
          render_bad_request(message: "Invalid Date. Format is YYYY-MM-DD.")
          return false
        end
      end
    end

    def sanitize_program_slug
      if params[:program]
        @program = Program.find_by_slug(params[:program].to_s)

        if !@program
          render_not_found(message: "Program not found. (#{params[:program]})")
        end
      end
    end
  end
end

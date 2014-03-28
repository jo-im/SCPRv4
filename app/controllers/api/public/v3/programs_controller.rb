module Api::Public::V3
  class ProgramsController < BaseController

    AIR_STATUSES = [
      "onair",
      "online",
      "archive",
      "hidden"
    ]

    before_filter :sanitize_slug, only: [:show]
    before_filter :sanitize_air_status, only: [:index]

    def index
      if @statuses
        @programs = Program.find_by_air_status(@statuses)
      else
        @programs = Program.all
      end
      respond_with @programs
    end


    def show
      @program = Program.find_by_slug(@slug)

      if !@program
        render_not_found and return false
      end

      respond_with @program
    end

    private

    def sanitize_air_status
      return true if !params[:air_status]
      @statuses = []
      statuses = params[:air_status].to_s.split(',').uniq.each do |status|
        if AIR_STATUSES.include?(status)
          @statuses.push(status)
        end
      end
      @statuses
    end

  end
end

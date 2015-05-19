module Api::Public::V3
  class ProgramsController < BaseController

    AIR_STATUSES = [
      "onair",
      "online",
      "archive",
      "hidden"
    ]

    before_filter :sanitize_slug, only: [:show, :months]

    before_filter \
      :set_hash_conditions,
      :sanitize_air_status,
      only: [:index, :months]


    def index
      @programs = Program.where(@conditions)
      respond_with @programs
    end


    def show
      @program = Program.find_by_slug(@slug)

      if !@program
        render_not_found and return false
      end

      respond_with @program
    end

    def months
      @program = KpccProgram.find_by_slug(@slug) || ExternalProgram.find_by_slug(@slug)
      @months = @program.episode_months params[:year]
      respond_with @months
    end

    private

    def sanitize_air_status
      return true if !params[:air_status]

      @conditions[:air_status] = params[:air_status].to_s.split(',').uniq
      .select { |s| AIR_STATUSES.include?(s) }
    end
  end
end

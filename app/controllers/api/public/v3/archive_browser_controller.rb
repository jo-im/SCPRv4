module Api::Public::V3
  class ArchiveBrowserController < BaseController

    before_filter :sanitize_slug, :find_program, only: [:index, :years, :months]

    def index
      date = Time.zone.parse("#{params[:year]}-#{params[:month]}-01")
      @episodes = @program.episodes.published.where(air_date: date.beginning_of_month..date.end_of_month)
      respond_with @episodes
    end

    def months
      @months = @program.episode_months params[:year]
      respond_with @months
    end

    def years
      @years = @program.episode_years
      respond_with @years
    end

    private

    def find_program
      @program = KpccProgram.find_by_slug(@slug) || ExternalProgram.find_by_slug(@slug)
      if @program.nil?
        render_not_found(message: "Program not found. (#{params[:id]})")
      end
    end

  end
end

module Api::Public::V3
  class ScheduleOccurrencesController < BaseController

    MAXIMUM_LENGTH      = 1.week
    MAXIMUM_LOOKAHEAD   = 1.month

    DEFAULTS = {
      length: 1.week
    }

    before_filter \
      :sanitize_start_time,
      :sanitize_length,
      only: [:index]

    before_filter :sanitize_time, only: [:show]

    #---------------------------

    def index
      @pledge_drive = false
      @display_pledge_status = params[:pledge_status]

      @schedule_occurrences = Rails.cache.fetch("/api/v3/schedule/#{@start_time}/#{@length}/#{@pledge_drive}/#{@display_pledge_status}", expires_in: 5.minutes) do
        ScheduleOccurrence.block(@start_time, @length)
      end

      respond_with @schedule_occurrences
    end

    #---------------------------

    def show
      @schedule_occurrence = ScheduleOccurrence.on_at(@time)
      respond_with @schedule_occurrence
    end

    #---------------------------

    private

    def sanitize_start_time
      if params[:start_time].present?
        @start_time = Time.zone.at(params[:start_time].to_i)

        if @start_time > MAXIMUM_LOOKAHEAD.from_now
          render_bad_request(
            :message => "Can't determine schedule that far in the future."
          ) and return false
        end
      else
        @start_time = Time.zone.now.beginning_of_week
      end
    end

    def sanitize_length
      if params[:length].present?
        length = params[:length].to_i
        @length = length > MAXIMUM_LENGTH ? MAXIMUM_LENGTH : length
      else
        @length = defaults[:length]
      end
    end

    def sanitize_time
      if params[:time].present?
        @time = Time.zone.at(params[:time].to_i)

        if @time > MAXIMUM_LOOKAHEAD.from_now
          render_bad_request(
            :message => "Can't determine schedule that far in the future."
          ) and return false
        end
      else
        @time = Time.zone.now
      end
    end
  end
end

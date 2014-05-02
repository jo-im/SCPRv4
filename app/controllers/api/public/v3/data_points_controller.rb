module Api::Public::V3
  class DataPointsController < BaseController
    before_filter :sanitize_slug, only: [:show]

    before_filter \
      :set_hash_conditions,
      :sanitize_response_format,
      :sanitize_group,
      only: [:index]

    RESPONSE_FORMATS = %w[ full simple ]

    DEFAULTS = {
      :response_format => "full"
    }

    def index
      @data_points = DataPoint.order("updated_at desc").where(@conditions)
      respond_with @data_points
    end


    def show
      @data_point = DataPoint.where(data_key: @slug).first

      if !@data_point
        render_not_found and return false
      end

      respond_with @data_point
    end


    private

    def sanitize_data_key
      @key = params[:key].to_s
    end

    def sanitize_response_format
      format    = params[:response_format]
      default   = DEFAULTS[:response_format]

      @response_format = RESPONSE_FORMATS.include?(format) ? format : default
    end

    # TODO: Support multiple groups?
    # That would make the "simple" response object pretty confusing
    def sanitize_group
      return if !params[:group]
      @conditions[:group_name] = params[:group].to_s
    end
  end
end

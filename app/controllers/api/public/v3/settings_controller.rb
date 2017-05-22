module Api::Public::V3
  class SettingsController < BaseController

    before_filter :get_context, only: [:index]

    def index
      @settings = Setting.where(context: @context).where.not(context: nil)
      if @context == "global"
        @pledge_drive = PledgeDrive.happening.order("starts_at DESC").first
      end
      respond_with @settings
    end

  private
    def get_context
      @context = params[:context] || "global"
    end
  end
end
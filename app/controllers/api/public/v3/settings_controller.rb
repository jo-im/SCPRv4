module Api::Public::V3
  class SettingsController < BaseController

    def index
      @settings = Setting.where(context: [params[:context], 'global']).where.not(context: nil)
      @pledge_drive = PledgeDrive.happening.order("starts_at DESC").first
      respond_with @settings
    end
    
  end
end
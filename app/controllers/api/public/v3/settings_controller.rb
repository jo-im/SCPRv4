module Api::Public::V3
  class SettingsController < BaseController

    def index
      @context  = [params[:context], 'global']
      @settings = Setting.where(context: @context).where.not(context: nil).to_a
      @pledge_drive = PledgeDrive.happening.order("starts_at DESC").first
      if @pledge_drive
        @settings.unshift @pledge_drive.to_setting
        @settings.uniq!
      end
      respond_with @settings
    end
    
  end
end
module Api::Public::V3
  class SettingsController < BaseController

    def index
      @context  = [params[:context], 'global']
      @settings = Setting.where(context: @context).where.not(context: nil).to_a
      @pledge_drive = PledgeDrive.happening.order("starts_at DESC").first
      if @pledge_drive
        @pledge_drive_setting = Setting.where(context: params[:context], key: "pledge_drive").first_or_initialize
        @pledge_drive_setting.value ||= {}
        @pledge_drive_setting.value["starts_at"] = @pledge_drive.starts_at
        @pledge_drive_setting.value["ends_at"]   = @pledge_drive.ends_at
        @settings.unshift @pledge_drive_setting
        @settings.uniq!
      end
      respond_with @settings
    end
    
  end
end
class ListenController < ApplicationController
  before_filter :check_pledge_status, :require_pledge_token, only: [:pledge_free_stream]

  def index
    # grab eight hours worth of schedule, starting now
    # we don't need start time yet, so no need to go backward
    @schedule = ScheduleOccurrence.block(Time.zone.now, 8.hours, true)

    # grab the latest edition
    @latest_edition  = Edition.published.includes(:slots).first

    render layout: false
  end

  def pledge_free_stream
    # grab eight hours worth of schedule, starting now
    @schedule = ScheduleOccurrence.block(Time.now, 8.hours)

    if cookies[:member_session].present?

      # render pledge-free stream page
      render layout: false

    elsif params.has_key?(:pledgeToken)

      pledge_token = params[:pledgeToken]
      member = Member.where(pledge_token: pledge_token)

      # redirect to flat page if we can't find a valid user
      return redirect_to '/listen_live/pledge-free/error' unless member.present?

      cookies.permanent[:member_session] = pledge_token
      render layout: false
    end
  end

  private

  def check_pledge_status
    return redirect_to("/listen_live/pledge-free/off-air") unless PledgeDrive.happening?
  end

  def require_pledge_token
    redirect_to '/listen_live/pledge-free/error' unless params.has_key?(:pledgeToken) || cookies[:member_session].present?
  end
end

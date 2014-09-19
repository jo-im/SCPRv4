class ListenController < ApplicationController
  before_filter :require_pledge_token, only: [:pledge_free_stream]

  def index
    # grab eight hours worth of schedule, starting now
    @schedule = ScheduleOccurrence.block(Time.now, 8.hours)

    # grab our homepage stories
    @homepage = Homepage.published.first

    render layout: false
  end

  def pledge_free_stream
    # grab eight hours worth of schedule, starting now
    @schedule = ScheduleOccurrence.block(Time.now, 8.hours)

    if cookies[:member_session].present?

      render layout: false

    elsif params[:pledgeToken].present?
      user = Parse::Query.new("PFSUser")
      live_listener = user.eq("pledgeToken", params[:pledgeToken])
      sustaining_member = live_listener.get.first

      # redirect to flat page
      return redirect_to '/pledge-free/error' unless sustaining_member.present?

      sustaining_member["viewsLeft"] = Parse::Increment.new(-1)
      sustaining_member.save
      if sustaining_member["viewsLeft"] == 0
        sustaining_member["pledgeToken"] = nil
        sustaining_member.save
      end
      cookies[:member_session] = params[:pledgeToken]
      render layout: false
    end
  end

  private

  def require_pledge_token
    redirect_to root_path unless params[:pledgeToken].present? || cookies[:member_session].present?
  end
end

class ListenController < ApplicationController
  before_filter :require_parse_key, only: [:pledge_free_stream]

  def index
    # grab eight hours worth of schedule, starting now
    @schedule = ScheduleOccurrence.block(Time.now, 8.hours)

    # grab our homepage stories
    @homepage = Homepage.published.first

    render layout: false
  end

  def pledge_free_stream
    if cookies[:member_session].present?

      render layout: false

    elsif params[:parse_key].present?
      user = Parse::Query.new("PFSUser")
      live_listener = user.eq("sustainingMembershipToken", params[:parse_key])
      sustaining_member = live_listener.get.first

      return redirect_to root_path unless sustaining_member.present?

      sustaining_member["viewsLeft"] = Parse::Increment.new(-1)
      sustaining_member.save
      if sustaining_member["viewsLeft"] == 0
        sustaining_member["sustainingMembershipToken"] = nil
        sustaining_member.save
      end
      cookies[:member_session] = params[:parse_key]
      render layout: false
    end
  end

  private

  def require_parse_key
    redirect_to root_path unless params[:parse_key].present? || cookies[:member_session].present?
  end
end

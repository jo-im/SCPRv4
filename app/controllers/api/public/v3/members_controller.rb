module Api::Public::V3
  class MembersController < BaseController
    def show
      if !params[:id] || !(@member = Member.where(pledge_token: params[:id]).first)
        render_not_found and return false
      end

      respond_with @member
    end
  end
end


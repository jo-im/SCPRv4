module Api::Public::V3
  class MembersController < BaseController
    def show
      if params[:id] && (@member = Member.where("pledge_token LIKE (?)",
                                                params[:id]).first)
        if @member.views_left > 0
          @member.views_left -= 1
          @member.save
          respond_with @member
        else
          render_not_found and return false
        end
      else
        render_not_found and return false
      end
    end
  end
end

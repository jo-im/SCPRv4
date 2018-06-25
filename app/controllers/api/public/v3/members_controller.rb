module Api::Public::V3
  class MembersController < BaseController
    def show
      if !params[:id] || !(@member = Member.where("pledge_token LIKE (?)", "#{params[:id]}%").first)

        # Find out if it's in Parse
        parse_user_query = Farse::Query.new("PfsUser")
        parse_user_query.eq("pledgeToken", params[:id])
        authorized_user = parse_user_query.get.first
        if authorized_user.present?
          authorized_user["viewsLeft"] = Farse::Increment.new(-1)
          Member.create_from_parse(authorized_user)
        else
          render_not_found and return false
        end
      end
      respond_with @member
    end
  end
end

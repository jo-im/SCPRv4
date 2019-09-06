##
# Concern::Controller::Searchable
#
# Requirements:
# * The model for this class (`model`) is indexed by Sphinx
# * This controller has been bootstrapped by Outpost
#
module Concern
  module Controller
    module Searchable
      # Action
      def search
        breadcrumb "Search"


        body = {
          query: {
            query_string: {
              query:              params[:query],
              default_operator:   "AND",
            }
          },
          sort: [{"created_at"=>{:order=>(order_direction||"desc").downcase}}]
        }

        @results = model.search(body).page(params[:page]||1).per(50)
        @records = @results.records
      end

      #-----------------

      private

      def search_params
        @search_params ||= {
          :order => order
        }
      end
    end
  end
end

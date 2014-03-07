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

        @records = model.search(Riddle::Query.escape(params[:query].to_s), {
          :page     => params[:page] || 1,
          :per_page => 50
          }.merge(search_params)
        )
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

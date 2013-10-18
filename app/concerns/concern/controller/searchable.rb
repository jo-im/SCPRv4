##
# Concern::Controller::Searchable
#
# Requirements:
# * This model for this class (`model`) is indexed by Sphinx
# * This controller has been bootstrapped by Outpost
#
module Concern
  module Controller
    module Searchable
      # Action
      def search
        breadcrumb "Search"
        
        @records = model.search(params[:query], {
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

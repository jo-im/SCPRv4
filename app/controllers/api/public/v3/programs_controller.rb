module Api::Public::V3
  class ProgramsController < BaseController

    AIR_STATUSES = [
      "onair",
      "online",
      "archive",
      "hidden"
    ]

    before_filter :sanitize_slug, only: [:show, :date_aggregation]

    before_filter \
      :set_hash_conditions,
      :sanitize_air_status,
      only: [:index]


    def index
      @programs = Program.where(@conditions)
      respond_with @programs
    end


    def show
      @program = Program.find_by_slug(@slug)

      if !@program
        render_not_found and return false
      end

      respond_with @program
    end

    def date_aggregation
      @program = Program.find_by_slug(params[:id])
      query = {:query=>
        {:filtered=>
          {:query=>{:match_all=>{}}, :filter=>{:term=>{:published=>"true", "show.slug" => params[:id]}}}},
       :sort=>[{"public_datetime"=>{:order=>"desc"}}],
       :size=>10,
       :from=>0,
       :aggs=>
        {:years=>
          {
            :date_histogram=>{:field=>"public_datetime", :interval=>"year", :time_zone=>"-07:00", :format=>"YYYY"},
            :aggs => {
              :months=> {
                :date_histogram=>{:field=>"public_datetime", :interval=>"month", :time_zone=>"-07:00"}
              }
            }
          }
        }
      }
      @result = ContentBase.es_client.search(index: ContentBase.es_index, type: "show_episode", body: query)
      respond_with @result
    end


    private

    def sanitize_air_status
      return true if !params[:air_status]

      @conditions[:air_status] = params[:air_status].to_s.split(',').uniq
      .select { |s| AIR_STATUSES.include?(s) }
    end
  end
end

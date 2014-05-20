module Job
  class ElectionResults < Base
    PROPS = {}

    def data_key_map
      return {} if !@data

      {
        "data point key" => "XML Value"
      }
    end


    class << self
      def perform
        job = new
        job.load_data
        job.update_data
      end
    end


    def load_data
      Dir["/web/scprv4/sosxml/*"].each do |file|
        # Load XML
      end
    end


    def update_data
      data_points = DataPoint.where(group: "election-june2014")
      data        = DataPoint.to_hash(data_points)

      data_key_map.keys.each do |key|
        data[key].object.update_attribute(:data, data_key_map[key].to_s)
      end
    end
  end
end

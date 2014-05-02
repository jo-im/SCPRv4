json.cache! [Api::Public::V3::VERSION, "simple", data_points.last] do
  data_points.each do |data_point|
    json.set! data_point.data_key, data_point.data_value
  end
end

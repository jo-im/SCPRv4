case response_format ||= "full"
when "simple"
  # This is the equivalent of the "to_hash" method on DataPoint
  # We would handle the iteration in this template to be consistent,
  # but then we'd have to handle caching in this template, and I'd
  # rather do this than that.
  json.partial! api_view_path("data_points", "data_points_simple"),
    data_points: data_points

when "full"
  json.array! data_points do |data_point|
    json.partial! api_view_path("data_points", "data_point"),
      data_point: data_point
  end
end

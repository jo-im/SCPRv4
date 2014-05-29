json.partial! api_view_path("shared", "meta")

json.data_points do
  json.partial! api_view_path("data_points", "collection"),
    :data_points        => @data_points,
    :response_format    => @response_format
end

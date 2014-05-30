json.cache! [Api::Public::V3::VERSION, "full", data_point] do
  json.title         data_point.title
  json.group         data_point.group_name
  json.key           data_point.data_key
  json.value         data_point.data_value
  json.notes         data_point.notes
  json.updated_at    data_point.updated_at
end

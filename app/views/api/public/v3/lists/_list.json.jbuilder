json.cache! [Api::Public::V3::VERSION, "v1", list] do
  json.title         list.title
  json.context       list.context
  json.status        list.status
  json.start_time    list.start_time
  json.end_time      list.end_time
  json.created_at    list.created_at
  json.updated_at    list.updated_at
end

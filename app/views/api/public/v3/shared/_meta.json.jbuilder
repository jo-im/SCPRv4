json.meta do
  json.version Api::Public::V3::VERSION.to_s

  json.status do
    json.code response.status
    json.message response.message
  end
end

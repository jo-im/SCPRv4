json.partial! api_view_path("shared", "meta")

json.histogram do
  json.episode_count @result["hits"]["total"].to_i
  json.years @result["aggregations"]["years"]["buckets"].each do |year|
    json.year year["key_as_string"].to_i
    json.episode_count year["doc_count"]
    json.months year["months"]["buckets"].each do |month|
      json.month Time.parse(month["key_as_string"]).month
      json.name  Time.parse(month["key_as_string"]).strftime("%B")
      json.episode_count month["doc_count"]
    end
  end
end
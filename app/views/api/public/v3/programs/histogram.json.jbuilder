json.partial! api_view_path("shared", "meta")

json.histogram do
  json.episode_count @result["hits"]["total"]["value"].to_i
  json.years @result["aggregations"]["years"]["buckets"].each do |year|
    json.year           year["key_as_string"].to_i
    json.episode_count  year["doc_count"]
    json.months         year["months"]["buckets"].each do |month|
      date = Time.parse(month["key_as_string"])
      json.year           date.year
      json.month          date.month
      json.name           date.strftime("%B")
      json.episode_count  month["doc_count"]
    end
  end
end

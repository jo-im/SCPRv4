json.partial! api_view_path("shared", "meta")

json.list do
  json.id            @list.id
  json.title         @list.title
  json.context       @list.context
  json.status        @list.status
  json.start_time    @list.start_time
  json.end_time      @list.end_time
  json.created_at    @list.created_at
  json.updated_at    @list.updated_at  
  json.items do
    json.partial! api_view_path("articles", "collection"),
      articles: @list_items
  end
end

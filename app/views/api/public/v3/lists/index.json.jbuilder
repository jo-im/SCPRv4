json.partial! api_view_path("shared", "meta")

json.lists do
  json.array! @lists do |list|
    json.id            list.id
    json.title         list.title
    json.type          list.content_type.split(',') if list.content_type
    json.context       list.context
    json.starts_at     list.starts_at
    json.ends_at       list.ends_at
    json.created_at    list.created_at
    json.updated_at    list.updated_at
    json.items do
      json.partial! api_view_path("articles", "collection"),
        articles: list.items.articles
    end
  end
end


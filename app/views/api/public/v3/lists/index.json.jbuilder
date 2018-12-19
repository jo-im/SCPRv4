json.partial! api_view_path("shared", "meta")

json.cache! ['/api/v3/lists', @context], expires_in: 5.minutes do
  json.lists do
    json.array! @lists do |list|
      json.id            list.id
      json.title         list.title
      json.types         list.content_type.split(',') if list.content_type
      json.context       list.context
      json.starts_at     list.starts_at
      json.ends_at       list.ends_at
      json.created_at    list.created_at
      json.updated_at    list.updated_at
      json.items do
        json.partial! api_view_path("articles", "collection"),
          articles: list.items.articles.length > 0 ?
            list.items.articles : list.deduped_category_items
      end
    end
  end
end


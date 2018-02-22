json.partial! api_view_path("shared", "meta")

json.list do
  json.id            @list.id
  json.title         @list.title
  json.type          @list.content_type
  json.context       @list.context
  json.starts_at     @list.starts_at
  json.ends_at       @list.ends_at
  json.created_at    @list.created_at
  json.updated_at    @list.updated_at  
  json.items do
    json.array! @list_items do |article|
      if article.obj_key.match("program")
        json.partial! api_view_path("programs", "program"), program: article.original_object
      else
        json.partial! api_view_path("articles", "article"), article: article
      end
    end
  end
end


json.cache! [Api::Public::V2::VERSION, "v4", article] do
  json.id           article.id
  json.title        article.title
  json.short_title  article.short_title
  json.published_at article.public_datetime
  json.byline       article.byline
  json.teaser       article.teaser.html_safe
  json.body         article.body.html_safe
  json.public_url   article.public_url


  asset = article.assets.first
  json.thumbnail asset ? asset.lsquare.tag : nil


  if article.category.present?
    json.category do
      json.partial! "api/public/v2/categories/category", category: article.category
    end
  end

  json.assets do |asset|
    json.partial! "api/public/v2/assets/collection", assets: article.assets
  end

  json.audio do
    json.partial! "api/public/v2/audio/collection", audio: article.audio
  end

  json.attributions article.attributions do |byline|
    json.name       byline.name
    json.role_text  ContentByline::ROLE_TEXT[ byline.role ]
    json.role       byline.role
  end



  json.permalink    article.public_url # Deprecated
end

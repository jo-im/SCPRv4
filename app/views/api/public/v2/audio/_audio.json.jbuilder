#json.cache! [Api::Public::V2::VERSION, "v2", audio] do
  json.id               audio.id
  json.description      audio.description
  json.url              audio_url_with_params(audio.url)
  json.byline           audio.byline
  json.uploaded_at      audio.created_at
  json.position         audio.position
  json.duration         audio.duration
  json.filesize         audio.size
  json.article_obj_key  audio.content.try(:obj_key) || ""

  json.content_obj_key  audio.content.try(:obj_key) || "" # Deprecated
#end

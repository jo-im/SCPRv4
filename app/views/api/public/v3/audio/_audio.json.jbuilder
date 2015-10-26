if content && content.is_a?(Article)
	context = content.show.try(:slug)
else
	context = audio.try(:content).try(:show).try(:slug)
end

#json.cache! [Api::Public::V3::VERSION, "v2", audio] do
  json.id               audio.id
  json.description      audio.description
  if audio.content_type == "ShowEpisode"
    json.url              url_with_params(audio.url, via: "api", context:context)
  else
    json.url              url_with_params(audio.url, context:context)
  end
  json.byline           audio.byline
  json.uploaded_at      audio.created_at
  json.position         audio.position
  json.duration         audio.duration
  json.filesize         audio.size
  json.article_obj_key  audio.content.try(:obj_key)
#end

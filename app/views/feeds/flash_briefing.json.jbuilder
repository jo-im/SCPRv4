json.array! @content do |content|
  json.uid  content.public_url
  json.updateDate Time.zone.now
  json.titleText content.title
  json.mainText content.teaser
  if audio = (content.audio || []).first
    json.streamUrl (audio.url || "").gsub("http://", "https://")
  end     
  json.redirectionUrl  content.public_url
end

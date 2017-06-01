json.array! @content do |content|
  json.uid  content.public_url
  json.updateDate content.public_datetime
  json.titleText content.title
  json.mainText content.teaser
  if audio = (content.audio || []).first
    json.streamUrl (audio.url || "").gsub("http://", "https://")
  end     
  json.redirectionUrl  content.public_url
end

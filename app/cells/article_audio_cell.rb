class ArticleAudioCell < Cell::ViewModel
  property :audio

  cache :show, expires_in: 10.minutes, :if => lambda { !@options[:preview] }  do
    [model.try(:cache_key), 'article_audio', 'v2']
  end

  def show
    render if audio_file
  end

  def audio_file
    model.try(:audio).try(:first)
  end

  def extra_audio
    model.audio[1..-1]
  end

  def horizontal
    render if audio_file
  end

  def vertical
    render if audio_file
  end

  def format_duration(secs)
    hours = Time.at(secs).utc.strftime("%H")
    minutes_and_seconds = Time.at(secs).utc.strftime("%M:%S")
    if hours == "00"
      minutes_and_seconds
    else
      "#{hours}:#{minutes_and_seconds}"
    end
  end

  def audio_size
    if audio_file.try(:size)
      (audio_file.size / 1000000).round(2)
    end
  end

  def audio_url url
    ApplicationHelper.url_with_params(url, context: @options[:audio_context], via: 'website')
  end

end

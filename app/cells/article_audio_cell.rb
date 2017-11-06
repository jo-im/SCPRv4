class ArticleAudioCell < Cell::ViewModel
  property :audio

  cache :show do
    if @options[:preview] != true
      model.try(:cache_key)
    end
  end

  def show
    render if audio_file
  end

  def audio_file
    file = nil
    model.audio.each do |audio_file|
      if audio_file.duration
        file = audio_file
        break
      end
    end
    return file
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

end

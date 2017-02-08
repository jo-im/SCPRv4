class EpisodeCell < Cell::ViewModel
  property :title
  def show
    render
  end

  def program
    @options[:program]
  end

  def air_date
    model.try(:air_date).try(:strftime, "%B %-d, %Y")
  end

  def audio_file(episode)
    file = nil
    episode.audio.each do |audio_file|
      if audio_file.duration
        file = audio_file
        break
      end
    end
    return file
  end

  def asset_path(resource)
    resource.try(:asset).try(:lsquare).try(:url) || "/static/images/fallback-img-square.png"
  end

  def program_title
    model.try(:title)
  end

  def public_path
    model.try(:public_path) || model.try(:original_object).try(:public_path)
  end

  def related_content
    model.try(:to_episode).try(:segments)
  end

  def comment_count_for(object, options={})
    if has_comments?(object)
      options[:class] = "comment_link social_disq #{options[:class]}"
      options["data-objkey"] = object.disqus_identifier
      link_to("0", (object.public_path + "#comments"), options)
    end
  end

  def has_comments?(object)
    object.respond_to?(:disqus_identifier)
  end

  def format_clip_duration(secs)
    if !secs
      return ''
    end
    time_format = secs >= 3600 ? "%-H HRS %M MIN %S SEC" : "%-M MIN %S SEC"
    Time.zone.at(secs).utc.strftime(time_format)
  end
end
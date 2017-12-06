class RelatedLinksCell < Cell::ViewModel
  include Orderable

  cache :show, expires_in: 10.minutes, :if => lambda { !@options[:preview] }  do
    [model.try(:cache_key), 'v2']
  end

  def show
    render if links.any?
  end

  def related_content
    model.try(:related_content) || []
  end

  def related_links
    model.try(:related_links) || []
  end

  def links
    # There's some legacy code here, but I'm keeping it because
    # just having it extracted from the template is an improvement,
    # and who knows if we might want to start using some of these
    # returned attributes again in the future.
    @links ||= (related_content + related_links).map do |content|
      classes     = "track-event"
      url         = nil
      title       = nil
      descriptor  = nil
      is_pij      = false
      if content.respond_to?(:link_type)
        begin
          domain = URI.parse(content.url.sub(/^([^\?]+)\?.*/,'\1')).host.sub(/^www\./, '')
        rescue
          domain = "Link"
        end

        kpcc_link = domain.split(".").include?("scpr")

        if content.link_type == "query"
          classes     += " query"
          descriptor  = "Contribute Your Voice"
          is_pij      = true
        elsif kpcc_link
          descriptor  = "Article"
        else
          classes     += " outbound" if !kpcc_link
          descriptor  = "Source: #{domain}"
        end

        url     = content.url
        title   = content.try(:title) || content.try(:headline)
      else
        # hopefully these are content...
        if content.try(:feature).try(:_key).present?
          classes += " #{content.feature._key.to_s}"
        elsif content.try(:feature).try(:key).present?
          classes += " #{content.feature.key.to_s}"
        end

        url     = content.public_path
        title   = content.try(:short_title) || content.try(:short_headline)

        descriptor = content.try(:feature).try(:name) || "Article"
      end

      OpenStruct.new({
        url: url,
        title: title,
        descriptor: descriptor,
        clases: classes,
        is_pij: is_pij
      })
    end
  end

end

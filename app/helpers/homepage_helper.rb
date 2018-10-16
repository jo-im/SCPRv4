module HomepageHelper
  def media_object size, options={}
    # This is really here just to improve the readability
    # of the homepage markup.
    translation = {
      "sm" => "sm",
      "small" => "sm",
      "med" => "med",
      "medium" => "med",
      "lg" => "lg",
      "large" => "lg",
      "none" => "med"
    }
    options[:nofigure] = true if size.to_s == "none"
    options[:size]     = translation[size.to_s]
    options[:klass]    = options[:class]
    options.delete     :class
    render partial: "shared/media/media", locals: options
  end
  def media_figure aspect, options={}
    options[:aspect] ||= aspect
    render partial: "shared/media/components/figure", locals: options
  end
  def media_label label, path=nil
    render partial: "shared/media/components/label", locals: {label: label, path: path}
  end
  def media_headline size, headline, url
    render partial: "shared/media/components/headline", locals: {size: size, headline: headline, url: url}
  end
  def media_teaser teaser, options={}
    locals = {teaser: teaser, klass: ""}
    if options[:columns]
      locals[:klass] = "text-columns--med-2"
    end
    render partial: "shared/media/components/teaser", locals: locals
  end
  def media_meta(feature:, public_datetime:, updated_at:)
    render partial: "shared/media/components/meta", locals: {feature: feature, public_datetime: public_datetime, updated_at: updated_at}
  end
  def media_extra content, contents
    render partial: "shared/media/components/extra", locals: {content: content, contents: contents}
  end
  def latest_from_laist
    # Perform a get request to the LAist RSS FEED, and return an empty array if it fails
    begin
      rss_feed_url = Rails.configuration.x.api.laist.rss_feed_url
      response = RestClient.get(rss_feed_url)
      response_hash = Hash.from_xml(response.body)

      if response_hash && response_hash["rss"] && response_hash["rss"]["channel"] && response_hash["rss"]["channel"]["item"]
        response_hash["rss"]["channel"]["item"].try(:first, 5)
      else
        []
      end
    rescue
      []
    end
  end
  def latest_stories content
    # Takes a collection of any model objects
    # that respond to ContentBase obj_key method.
    #
    # This is really only useful in the context of
    # the homepage, where we want to show some of
    # the latest [news] stories excluding the first two
    # stories on the homepage for visual reasons.
    ignore_ids = content
      .select{|c| (c.content_type || "").match("NewsStory")}
      .sort_by{|i| i.position}
      .first(2)
      .map{|c| c.content_id}
    # ^^^ Just doing a ruby sort here because we
    # don't actually have anything to query against
    # when we are previewing a homepage.
    NewsStory
      .where("status = 5", "category_id IS NOT NULL")
      .where("source = 'npr'")
      .where("id NOT IN (?)", ignore_ids)
      .order("published_at DESC").limit(5)
  end
  def render_right_aside index, &block
    klass = "right l-col l-col--sm-12 l-col--med-3"
    if block_given?
      content_tag :aside, class: klass do
        yield
      end
    else
      @tags ||= @homepage.tags.to_a
      content_tag :aside, class: klass do
        if index == 0
          # render position a
          render partial: "better_homepage/latest_headlines", locals: {content: @homepage.content}
        elsif index == 1
          # render position b
          render partial: "better_homepage/c_ad", locals: {slot: "b"}
        elsif index == 4
          # render psoition c
          render partial: "better_homepage/c_ad", locals: {slot: "c"}
        else
          # render tag cluster
          render partial: "better_homepage/tag_cluster", locals: {tag: @tags.shift, omit: [@homepage]}
        end
      end
    end
  end

  def render_tag_cluster
    @_tag_cluster_order ||= 8 # On mobile, we start displaying these at the 8th position.
    klass = "right"
    @tags ||= @homepage.tags.to_a
    content_tag :aside, class: klass, style: "order: #{@_tag_cluster_order};" do
      render partial: "better_homepage/tag_cluster", locals: {tag: @tags.shift, omit: [@homepage]}
    end
  ensure
    @_tag_cluster_order += 4 # Display the next one 4 positions down.
  end

  def for_each_tag! &block
    @tags ||= @homepage.tags.to_a
    @tags.length.times do
      yield
    end
  end

  def listen_live_tile schedule_occurrence
    if program = schedule_occurrence.try(:program)
      tile_path = "/program-tiles/#{program.slug}.jpg"
      if File.exist? File.expand_path "#{Rails.root}/public#{tile_path}"
        return tile_path
      elsif podcast_tile_url = program.try(:podcast).try(:image_url)
        return podcast_tile_url
      end
    end
    "/static/images/default-listen-live-tile.jpg" # Return the fallback tile if we don't break out of the method.
  end

end
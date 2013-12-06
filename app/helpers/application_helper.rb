module ApplicationHelper
  include Twitter::Autolink

  HEADSHOTS = [
    "personalities/stoltze.png",
    "personalities/peterson.png",
    "personalities/moore.png",
    "personalities/guzman-lopez.png",
    "personalities/julian.png",
    "personalities/watt.png",
    "personalities/oneil.png",
    "personalities/trujillo.png"
  ]


  def present(object, klass=nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end


  # A hash in which to store meta data for the template META tags.
  # This is what should be used in the <head> tag to build the META tags.
  def meta_information
    @meta_hash ||= {}
  end

  # Add meta tags to the meta_information hash.
  def meta_tags(hash)
    meta_information.merge!(hash)
  end


  #---------------------------
  # render_content takes a ContentBase object and a context, and renders
  # using the most specific version of that context it can find.
  #
  # For instance, if your content is a "news/story" and your context is
  # "lead", render_content will try:
  #
  # * shared/content/news/story/lead
  # * shared/content/news/lead
  # * shared/content/default/lead
  #
  def render_content(content, context, options={})
    return '' if content.blank?
    html = ''

    Array(content).compact.each do |article|
      # if we're caching, add content to the objects list
      if defined? @COBJECTS
        @COBJECTS << article
      end

      directory   = article.class.name.underscore
      tmplt_opts  = ["#{directory}/#{context}", "default/#{context}"]

      partial = tmplt_opts.find do |template|
        self.lookup_context.exists?(template, ["shared/content"], true)
      end

      html << render(
        "shared/content/#{partial}",
        :article => article.to_article,
        :options => options
      )
    end

    html.html_safe
  end


  # render_asset takes a ContentBase object and a context, and renders using
  # an optional asset_display attribute on the object.
  #
  # For example, given a context of "story", render_asset will check for an
  # asset_display attribute on the object.  If found (let's assume with a
  # value of "photo"), it will try to render:
  #
  # * shared/assets/story/photo
  # * shared/assets/default/photo
  # * shared/assets/story/default
  # * shared/assets/default/default
  def render_asset(content, options={})
    article = content.to_article
    context = options[:context] || "default"

    if article.assets.empty?
      html = if options[:fallback]
        render("shared/assets/#{context}/fallback", article: article)
      else
        ''
      end

      return html
    end

    if options[:template]
      tmplt_opts = Array(options[:template])
    else
      display = options[:display]
      display ||= if article.original_object.respond_to?(:asset_display)
        content.asset_display
      else
        "photo"
      end

      tmplt_opts = [
        "#{context}/#{display}",
        "default/#{display}",
        "#{context}/photo",
        "default/photo"
      ]
    end

    partial = tmplt_opts.find do |template|
      self.lookup_context.exists?(template, ["shared/assets"], true)
    end

    return '' if !partial

    render "shared/assets/#{partial}",
      :assets     => article.assets,
      :article    => article
  end

  #----------

  def random_headshot
    image_tag HEADSHOTS.sample
  end

  #----------
  # Render the tag necessary for the Smart Date JS to pick it up.
  # Arguments:
  # * datetime - An object that response to strftime
  # * options  -  * tag - The tag to use (default: 'time')
  #               * class - Any class to prepend to the defaults
  #               * Anything else gets merged into the tag as attributes.
  def smart_date_js(datetime, options={})
    return '' if !datetime.respond_to?(:strftime)

    options[:tag] ||= 'time'

    content_tag options.delete(:tag), nil, {
      "class" => "#{options.delete(:class)} smart smarttime",
      "data-unixtime" => datetime.to_i
    }.merge(options)
  end


  #----------
  # Render a byline for the passed-in content
  # If links is set to false, and the content has
  # bylines, this will yield the same as +content.byline+
  #
  # If the content doesn't have bylines, just return
  # "KPCC" for opengraph stuff.
  def render_byline(content, links=true)
    return "KPCC" if !content.respond_to?(:joined_bylines)

    elements = content.joined_bylines do |bylines|
      link_bylines(bylines, links)
    end

    ContentByline.digest(elements).html_safe
  end

  #---------------------------

  def render_contributing_byline(content,links=true)
    elements = content.joined_bylines do |bylines|
      link_bylines(bylines, links)
    end

    if elements[:contributing].present?
      "With contributions by #{elements[:contributing]}".html_safe
    else
      ""
    end
  end

  #---------------------------
  # Return an array of the passed-in bylines
  # either tranformed into links, or just
  # the name.
  #
  # This is mostly for +render_byline+ and
  # +render_contributing_byline+ to share.
  def link_bylines(bylines, links)
    bylines.map do |byline|
      if !!links && byline.user.try(:is_public)
        link_to byline.display_name, byline.user.public_path
      else
        byline.display_name
      end
    end
  end

  #---------------------------
  # Convert a given number of seconds into a human-readable duration.
  def format_duration(secs)
    if !secs
      return ''
    end

    [[60, :sec], [60, :min], [24, :hr], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end

  #----------

  def latest_arts(limit=2)
    ContentBase.search({
      :classes    => [NewsStory, BlogEntry, ShowSegment, ContentShell],
      :limit      => limit,
      :with       => { category_is_news: false },
      :without    => { category: false }
    }).map(&:to_article)
  end

  #----------

  def latest_news(limit=2)
    ContentBase.search({
      :classes    => [NewsStory, BlogEntry, ShowSegment, ContentShell],
      :limit      => limit,
      :with       => { category_is_news: true },
      :without    => { category: false }
    }).map(&:to_article)
  end

  #----------

  def link_to_audio(title, article, options={}) # This needs to be more useful
    article = article.to_article
    return nil if article.audio.empty?

    options[:class] = "audio-toggler #{options[:class]}"
    options[:title] ||= article.short_title
    options["data-duration"] = article.audio.first.duration

    content_tag :div, link_to(title, article.audio.first.url, options),
      :class => "story-audio inline"
  end

  #---------------------------

  def twitter_profile_url(handle)
    "https://twitter.com/#{handle.parameterize}"
  end

  #---------------------------

  def modal(cssClass, options={}, &block)
    content_for(:modal_content, capture(&block))
    render('shared/modal_shell', cssClass: cssClass, options: options)
  end

  #---------------------------

  def relaxed_sanitize(html)
    Sanitize.clean(html.to_s.html_safe, Sanitize::Config::RELAXED)
  end

  #---------------------------

  def split_collection(array, num)
    last_num  = array.size - num
    first     = array.first(num)
    last      = array.last(last_num < 0 ? 0 : last_num)
    return [first, last]
  end

  #----------

  def pij_source(content, options={})
    message = options[:message] || "This story was informed by KPCC listeners."

    if content.is_from_pij?
      render '/shared/pij_notice', message: message
    end
  end

  #----------
  # Render a timestamp inside of a time tag.
  #
  # time_tag uses i18n's `localize` method, which raises
  # if the date passed in doesn't respond to strftime, so we
  # need to check that this is the case before rendering the
  # time tag. Otherwise previewing unpublished content breaks.
  def timestamp(datetime)
    if datetime.respond_to?(:strftime)
      time_tag(datetime,
        format_date(datetime,
          :format   => :full_date,
          :time     => true
        ),
        :pubdate => true
      )
    end
  end


  #----------

  def comment_widget_for(object, options={})
    if has_comments?(object)
      content_widget('comment_count', object, options)
    end
  end

  def comments_for(object, options={})
    if has_comments?(object)
      content_widget('comments', object, { header: true }.merge(options))
    end
  end

  def comment_count_for(object, options={})
    if has_comments?(object)
      options[:class] = "comment_link social_disq #{options[:class]}"
      options["data-objkey"] = object.disqus_identifier

      link_to("Add your comments",
        object.public_path(anchor: "comments"), options)
    end
  end

  def has_comments?(object)
    object.respond_to?(:disqus_identifier)
  end


  #----------

  def content_widget(partial, object, options={})
    partial = "shared/cwidgets/#{partial}" if partial.chars.first != "/"

    render(partial, {
      :article  => object.to_article,
      :cssClass => ""
    }.merge(options))
  end

  alias_method :widget, :content_widget

  #---------------
  # These two methods are taken from EscapeUtils
  def html_escape(string)
    EscapeUtils.escape_html(string.to_s).html_safe
  end
  alias_method :h, :html_escape

  def url_encode(s)
    EscapeUtils.escape_url(s.to_s).html_safe
  end
  alias_method :u, :url_encode
end

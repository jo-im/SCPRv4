##
# ContentBase
#
# A set of definitions, collections, and utilities for
# content in the application.
#
module ContentBase
  extend self

  # This is dumb
  # I'm keeping it here because currently we don't have a way
  # to know for sure in the database if an article is published or
  # not, without checking it against the record's model.
  # So we have to assume that anything we're looking up in the
  # database that we want to be published uses the value of
  # ContentBase::STATUS_LIVE as its "published" status.
  # This should not and will not always be the case.
  # I think we just need to add a "published?" boolean to the
  # database so we can search against that.
  STATUS_LIVE = 5


  #--------------------
  # This used the be the array of "classes that are content",
  # but we've since moved away from that concept.
  # Don't use it - just be explicit about which classes you
  # want to search across.
  CONTENT_CLASSES = [
    NewsStory,
    ShowSegment,
    BlogEntry,
    ContentShell
  ]

  # Classes which are safe to fetch on the frontend.
  # This was added to make ContentMailer more safe.
  SAFE_CLASSES = [
    NewsStory,
    ShowSegment,
    BlogEntry,
    ContentShell,
    Event,
    PijQuery,
    ShowEpisode
  ]


  #--------------------
  # URLS to match in ::obj_by_url
  CONTENT_MATCHES = {
    %r{\A/news/\d+/\d\d/\d\d/(\d+)/.*}                => 'NewsStory',
    %r{\A/blogs/[-_\w]+/\d+/\d\d/\d\d/(\d+)/.*}       => 'BlogEntry',
    %r{\A/programs/[\w_-]+/\d{4}/\d\d/\d\d/(\d+)/.*}  => 'ShowSegment'
  }


  # Don't set any of these to 0, because ThinkingSphinx will
  # convert NULL to 0 and return incorrect results.
  ASSET_DISPLAY_IDS = {
    :slideshow    => 1,
    :video        => 2,
    :photo        => 3,
    :hidden       => 4
  }

  ASSET_DISPLAYS = ASSET_DISPLAY_IDS.invert


  def new_obj_key
    "contentbase:new"
  end

  #--------------------
  # Wrapper around ThinkingSphinx to just query all
  # ContentBase classes and mix in some default search
  # parameters.
  def search(*args)
    options     = args.extract_options!
    query       = args[0].to_s

    options.reverse_merge!({
      :classes     => CONTENT_CLASSES,
      :page        => 1,
      :order       => "public_datetime #{DESCENDING}",
      :retry_stale => true,
      :populate    => true
    })

    # We'll want to search only among live content 99% of the
    # time. For the times when we want unpublished stuff,
    # we can pass in `with: { is_live: [true, false] }`, for
    # example.
    options[:with] ||= {}
    options[:with].reverse_merge!(is_live: true)

    begin
      ThinkingSphinx.search(query, options)
    rescue  Riddle::ConnectionError,
            Riddle::ResponseError,
            ThinkingSphinx::SphinxError => e
      # In this one scenario, we need to fail gracefully from a Sphinx error,
      # because otherwise the entire website will be down if media isn't
      # available, or if we need to stop the searchd daemon for some reason,
      # like a rebuild.
      warn "Caught error in ContentBase.search: #{e}"
      Kaminari.paginate_array([]).page(0).per(0)
    end
  end

  #--------------------
  # Generate a teaser from the passed-in text.
  # If the text is blank, return an empty string.
  # If the first paragraph is <= target length, return
  # the first paragraph.
  # Otherwise get everything up to the target length,
  # the up to the next period.
  def generate_teaser(text, length=180)
    return '' if text.blank?
    teaser = ''

    stripped_body = ActionController::Base.helpers.strip_tags(text)
      .gsub("&nbsp;"," ").gsub(/\r/,'').strip

    stripped_body.match(/^.+/) do |match|
      first_paragraph = match[0]

      if first_paragraph.length <= length
        teaser = first_paragraph
      else
        shortened_paragraph = first_paragraph.match(/\A.{#{length}}[^\.]*\.?/)

        teaser = if shortened_paragraph
          "#{shortened_paragraph[0]}"
        else
          first_paragraph
        end
      end
    end

    teaser
  end


  # Safely fetch an object by a passed-in key.
  #
  # This is similar to Outpost.obj_by_key, except it only selects
  # published content and it lets us be explicit about which classes
  # to allow.
  #
  # This was originally added to make ContentMailer more safe.
  #
  # Arguments
  # * obj_key (String) - The object key to lookup.
  #
  # Examples
  #
  #   ContentBase.safe_obj_by_key("blog_entry-999") #=> #<BlogEntry...>
  #   ContentBase.safe_obj_by_key("admin_user-12") #=> nil
  def safe_obj_by_key(obj_key)
    obj = Outpost::obj_by_key(obj_key)

    if !obj || !SAFE_CLASSES.include?(obj.class) || !obj.published?
      return nil
    end

    obj
  end


  # safe_obj_by_key or raise error
  def safe_obj_by_key!(obj_key)
    safe_obj_by_key(obj_key) or raise ActiveRecord::RecordNotFound
  end


  #--------------------
  # Look to CONTENT_MATCHES to see if the passed-in URL
  # corresponds to any model.
  # Only find published articles.
  def obj_by_url(url)
    begin
      u = URI.parse(url)
    rescue URI::InvalidURIError
      return nil
    end

    if match = CONTENT_MATCHES.find { |k,_| u.path =~ k }
      # build the obj_key
      key       = match[1].constantize.obj_key($~[1])
      article   = Outpost.obj_by_key(key)
      article && article.published? ? article : nil
    else
      nil
    end
  end

  #---------------------
  # obj_by_url or raise
  def obj_by_url!(url)
    obj_by_url(url) or raise ActiveRecord::RecordNotFound, url
  end
end # ContentBase

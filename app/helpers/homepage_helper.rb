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
  def media_label label
    render partial: "shared/media/components/label", locals: {label: label}
  end
  def media_headline size, headline, url
    render partial: "shared/media/components/headline", locals: {size: size, headline: headline, url: url}
  end
  def media_teaser teaser
    render partial: "shared/media/components/teaser", locals: {teaser: teaser}
  end
  def media_meta(feature:, public_datetime:, updated_at:)
    render partial: "shared/media/components/meta", locals: {feature: feature, public_datetime: public_datetime, updated_at: updated_at}
  end
  def media_extra content, contents
    render partial: "shared/media/components/extra", locals: {content: content, contents: contents}
  end
  def latest_stories content
    # Takes a collection of any model objects
    # that respond to ContentBase obj_key method.
    #
    # This is really only useful in the context of
    # the homepage, where we want to show some of
    # the latest stories excluding the first two
    # stories on the homepage for visual reasons.
    ignore_obj_keys = content
      .order("position ASC")
      .limit(2).map{|c| "#{c.class.to_s.underscore}-#{c.id}"}
    ContentBase.active_query do |query|
      query
        .where("status = 5", "category_id IS NOT NULL")
        .where("id NOT IN (?)", ignore_obj_keys)
        .order("published_at DESC").limit(5)
    end 
  end  
  def render_right_aside index, &block
    klass = "right-aside l-col l-col--sm-12 l-col--med-3"
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
end
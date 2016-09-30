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
    options[:size] = translation[size.to_s]
    render partial: "shared/media/media", locals: options
  end
  def media_figure aspect, options={}
    options[:aspect] = aspect
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
  def media_meta feature:, public_datetime:, updated_at:
    render partial: "shared/media/components/meta", locals: {feature: feature, public_datetime: public_datetime, updated_at: updated_at}
  end
  def media_extra content, contents
    render partial: "shared/media/components/extra", locals: {content: content, contents: contents}
  end
end
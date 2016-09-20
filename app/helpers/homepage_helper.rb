module HomepageHelper
  def media_object kind, options={}
    # This is really here just to improve the readability
    # of the homepage markup.
    render partial: "better_homepage/media/shared/#{kind}", locals: options
  end
  def media_figure kind, options={}
    render partial: "better_homepage/media/shared/figure_#{kind}", locals: options
  end
  def media_label label
    render partial: "better_homepage/media/shared/label", locals: {label: label}
  end
  def media_headline headline, url
    render partial: "better_homepage/media/shared/headline", locals: {headline: headline, url: url}
  end
  def media_teaser teaser
    render partial: "better_homepage/media/shared/teaser", locals: {teaser: teaser}
  end
  def media_meta feature:, public_datetime:, updated_at:
    render partial: "better_homepage/media/shared/meta", locals: {feature: feature, public_datetime: public_datetime, updated_at: updated_at}
  end
  def media_extra content, contents
    render partial: "better_homepage/media/shared/extra", locals: {content: content, contents: contents}
  end
end
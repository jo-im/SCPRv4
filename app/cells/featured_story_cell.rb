class FeaturedStoryCell < Cell::ViewModel
  property :title
  property :public_path
  property :teaser
  property :tag
  property :obj_key
  property :byline

  def program
    render
  end

  def vertical
    render
  end

  def category_view
    render
  end

  def order
    @options[:order] || "1"
  end

  def byline
    model.try(:byline)
  end

  def teaser
    model.try(:teaser)
  end

  def title
    model.try(:short_title) || model.try(:short_headline)
  end

  def air_date
    # model.try(:air_date).try(:strftime, "%B %-d, %Y")
    model.try(:public_datetime).try(:strftime, "%B %-d, %Y")
  end

  def program_title
    model.try(:show).try(:title)
  end

  def asset_path
    model.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def category_title
    category.try(:title)
  end

  def tag
    (model.try(:tags) || []).first
  end

  def asset_attribution
    model.try(:asset).try(:owner)
  end

  def related_content
    @related_content ||= model.try(:related_content) || model.try(:segments)
  end

  def public_path
    model.try(:public_path) || model.try(:original_object).try(:public_path)
  end

  def blog_content
    @blog_content ||= if blog
      blog.entries.limit(2)
    else
      []
    end
  end

  def topic_articles
    tag.try(:articles, limit: 2,without:{obj_key: obj_key})
  end

  def category
    @category ||= model.try(:category)
  end

  def blog
    @blog ||= @options[:blog] || model.try(:blog)
  end


end

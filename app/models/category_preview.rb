class CategoryPreview
  DEFAULTS = {
    :limit => 5
  }

  DECAY_RATES = {
    :featured_comments    => -0.04,
    :slideshows           => -0.01,
    :segments             => -0.02
  }

  INITIAL_SCORES = {
    # slideshow initial scores are 5 * number of slides
    :slideshows           => 5,
    :featured_comments    => 20,
    :segments             => 10
  }

  attr_reader \
    :category,
    :articles,
    :top_article,
    :bottom_articles,
    :sorted_articles,
    :feature


  def initialize(category, options={})
    limit = options[:limit] || DEFAULTS[:limit]

    @category = category
    @exclude  = Array(options[:exclude])

    @articles = ContentBase.search({
      :classes    => [NewsStory, BlogEntry, ContentShell, ShowSegment],
      :limit      => limit,
      :with       => { category: @category.id },
      :without    => { obj_key: @exclude.map(&:obj_key_crc32) }
    }).map(&:to_article)

    @top_article      = find_top_article
    @bottom_articles  = find_bottom_articles

    @feature = find_feature
  end


  private

  def find_feature
    # lower decay decays more slowly. eg. rate of -0.01 
    # will have a lower score after 3 days than -0.05

    candidates = []

    featured = @category.comment_bucket.comments.published.first

    if featured.present?
      candidates << {
        :content  => featured,
        :score    => INITIAL_SCORES[:featured_comments] * Math.exp(DECAY_RATES[:featured_comments] * hours_ago(featured.created_at)),
        :metric   => :comment
      }
    end

    slideshow = ContentBase.search({
      :classes     => [NewsStory, BlogEntry, ShowSegment],
      :limit       => 1,
      :with        => {
        :category     => @category.id,
        :is_slideshow => true
      },
      :without => { obj_key: @exclude.map(&:obj_key_crc32) }
    })

    if slideshow.any?
      slideshow = slideshow.first

      candidates << {
        :content  => slideshow,
        :score    => (INITIAL_SCORES[:slideshows] + slideshow.assets.size) * Math.exp(DECAY_RATES[:slideshows] * hours_ago(slideshow.published_at)),
        :metric   => :slideshow
      }
    end

    segments = ContentBase.search({
      :classes     => [ShowSegment],
      :limit       => 1,
      :with        => { category: self.id },
      :without => { obj_key: @exclude.map(&:obj_key_crc32) }
    })

    if segments.any?
      seg = segments.first

      candidates << {
        :content  => seg,
        :score    => INITIAL_SCORES[:segments] * Math.exp(DECAY_RATES[:segments] * hours_ago(seg.published_at)),
        :metric   => :segment
      }
    end

    if candidates.any?
      return candidates.sort_by { |c| -c[:score] }
    else
      return nil
    end
  end

  def find_top_article
    @articles.find { |a| a.assets.any? }
  end

  def find_bottom_articles
    bottom = if @top_article
      @articles.select { |a| a.id != @top_article.id }
    else
      @articles
    end

    bottom.sort_by(&:publc_datetime)
  end

  def hours_ago(time)
    (Time.now - time) / 1.hour.to_i
  end
end

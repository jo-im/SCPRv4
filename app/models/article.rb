require 'zlib'

# An article is an abstract object, which is not persisted,
# but rather meant to be built manually from the attributes
# of another object.
#
# An Article should be the publc API for the parts of our
# presentational layer which mix different types of content.
# So in the areas where we're displaying blog entries, news
# stories, events, etc. all together, we shouldn't have to
# worry about whether one of the classes has defined an
# "audio" instance method, for example. We just coerce
# everything into an Article, and then *know* that it will
# work. This eliminates a lot of the "fakery" going on in
# our classes - stuff like `def teaser; self.body; end`.
#
# This also makes it super-easy to mix any content into the
# normal flow of things. If one day we decided that Bios
# should show up in the normal rotation on the homepage
# (this is a contrived example to illustrate the point),
# it would be a simple matter of defining a `to_article`
# instance method on the Bio class. How a Bio gets coerced
# into an Article is up to the developer.
#
# An Article object doesn't do anything fancy. It just acts
# exactly the way we need it to.
#
# This should pretty much match up with what our client API
# response is, but it doesn't necessarily have to.

class Article
  #include Concern::Methods::AbstractModelMethods
  include ActiveModel::Model

  VERSION = 4

  attr_accessor \
    :original_object,
    :id,
    :title,
    :short_title,
    :public_datetime,
    :teaser,
    :body,
    :category,
    :assets,
    :audio,
    :attributions,
    :byline,
    :edit_path,
    :public_path,
    :tags,
    :feature,
    :created_at,
    :updated_at,
    :published,
    :blog,
    :show,
    :related_content,
    :links,
    :asset_display,
    :disqus_identifier,
    :abstract,
    :asset_scheme,
    :from_pij

  alias_attribute :short_headline, :short_title

  def initialize(attributes={})
    attributes.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if attributes
    super()
  end

  def method_missing method_name, *args
    if method_name.match(/\w*=$/)
      ## Define an accessor if it doesn't already exist.
      class_eval{attr_accessor method_name.to_s.gsub("=", "")} unless respond_to?(method_name)
      send(method_name, *args)
    else
      super
    end
  end

  def context
    # Normally, we would use this as a "context" parameter
    # that we provide with our audio URLs to know within
    # what context they are being served.
    if slug = (show || blog).try(:slug)
      return slug
    end
    if original_object.class.to_s == "NewsStory"
      "news"
    end
  end

  def to_article
    self
  end

  def get_article
    self
  end

  def to_abstract
    @to_abstract ||= Abstract.new({
      :original_object        => self,
      :headline               => self.title,
      :summary                => self.teaser,
      :source                 => self.byline,
      :url                    => self.public_url,
      :assets                 => self.assets,
      :audio                  => self.audio,
      :category               => self.category,
      :article_published_at   => self.public_datetime
    })
  end

  def to_grand_central_article
    {
      _id: obj_key,
      title: title,
      shortTitle: short_title,
      teaser: teaser,
      link: {
        title: title,
        href: public_url,
        type: "text/html"
      },
      assets: [
        {
          title: asset.try(:title) || "An asset.",
          description: asset.try(:description),
          href: asset.try(:full).try(:url),
          type: "image/jpeg"
        }.delete_if{|k, v| v.nil?}
      ],
      body: body,
      abstract: abstract,
      source: "scpr.org",
      publishedAt: public_datetime.iso8601,
      updatedAt: updated_at.iso8601,
      byline: byline
    }.to_json
  end

  def original_object
    @original_object ||= Outpost.obj_by_key(self.id)
  end

  def obj_key
    self.id
  end

  def obj_class
    if @original_object
      @original_object.class.name.underscore
    else
      self.id.split("-")[0]
    end
  end

  def cache_key
    if self.id && self.updated_at
      "#{self.id}-#{ self.updated_at.to_i }-#{Article::VERSION}"
    else
      nil
    end
  end

  def public_url
    # ContentShells give a fully-qualified URL as their public_path. Don't
    # add on if that's the case
    if self.public_path =~ /^http/
      self.public_path
    else
      if Rails.application.default_url_options[:host]
        "#{Rails.application.default_url_options[:protocol] || 'http'}://#{Rails.application.default_url_options[:host]}#{self.public_path}"
      else
        self.public_path
      end
    end
  end

  def edit_url
    "#{Rails.application.default_url_options[:protocol] || 'http'}://#{Rails.application.default_url_options[:host]}#{self.edit_path}"
  end

  def asset
    @asset ||= self.assets.first || AssetHost::Asset::Fallback.new
  end

  def feature
    @feature ? ArticleFeature.find_by_key(@feature) : nil
  end

  def obj_key_crc32
    @obj_key_crc32 ||= Zlib.crc32(self.id)
  end

  def related_content_articles
    article_ids = related_content.map(&:id)
    ContentBase.search(with: { obj_key: article_ids })
  end

  def thumbnail
    asset.try(:asset).try(:json).try(:[], 'urls').try(:[], 'thumb')
  end

  # -- getters -- #

  def disqus_identifier
    @disqus_identifier ||= original_object.try(:disqus_identifier)
  end

  def asset_display
    @asset_display || "photo"
  end

  def assets
    # Assets that are meant to be displayed outside the article body. i.e. not inline
    (@assets||[]).collect do |a|
      ContentAsset.new(a.to_hash.merge({id:a.id, inline: a.inline}))
    end.reject(&:inline)
  end

  def inline_assets
    # Only assets that appear within the body of the article.
    (@assets||[]).collect do |a|
      ContentAsset.new(a.to_hash.merge({id:a.id, inline: a.inline}))
    end.select(&:inline)
  end

  def tags
    (@tags||[]).collect do |t|
      Tag.new(t.to_hash)
    end
  end

  def audio
    (@audio||[]).collect do |a|
      Audio.new(a.to_hash)
    end
  end

  def related_content
    @related_content || []
  end

  def links
    @links || []
  end

  def attributions
    (@attributions||[])
  end

  def category
    # FIXME: This is a hack while we figure out if a slightly deflated category is breaking the iPad app
    if @category && !@category.title?
      @category = Category.find_by_id(@category.id)
    end

    @category
  end

  def abstract
    if @abstract && !@abstract.empty?
      @abstract
    else
      teaser
    end
  end

  def from_pij?
    @from_pij || false
  end

  # -- setters -- #

  def related_content=(content)
    @related_content = (content||[]).collect do |c|
      Hashie::Mash.new(c)
    end.compact
  end

  def links=(content)
    @links = (content || []).collect do |c|
      Hashie::Mash.new(c)
    end
  end

  def assets=(assets)
    @assets = (assets||[]).collect do |a|
      Hashie::Mash.new(id: a.id, asset_id:a.asset_id, caption:a.caption, position:a.position, inline: a.inline, external_asset: a.external_asset)
    end
  end

  def audio=(audio)
    @audio = (audio||[]).collect do |a|
      Hashie::Mash.new(
        description:  a.description,
        byline:       a.byline,
        url:          a.url,
        size:         a[:size] || a.size,
        duration:     a.duration,
        content_type: a.content_type,
      )
    end
  end

  def category=(category)
    @category =  category ? Hashie::Mash.new(id:category.id, slug:category.slug) : nil
  end

  def tags=(tags)
    @tags = (tags||[]).collect do |t|
      Hashie::Mash.new(slug:t.slug, title:t.title)
    end
  end

  def blog=(blog)
    @blog = blog ? Hashie::Mash.new( id:blog.id, slug:blog.slug, name:blog.name ) : nil
  end

  def show=(show)
    @show = show ? Hashie::Mash.new( id:show.id, slug:show.slug, title:show.title ) : nil
  end

  def attributions=(bylines)
    @attributions = (bylines||[]).collect do |a|
      if a.is_a? ContentByline
        Hashie::Mash.new(name:a.display_name, user_id:a.user_id, role:a.role)
      else
        Hashie::Mash.new(name:a.name,user_id:a.user_id,role:a.role)
      end
    end
  end

  def feature=(feature)
    f = nil

    if feature.is_a?(ArticleFeature)
      f = feature.key
    elsif feature.is_a?(String)
      f = feature
    else
      f = nil
    end

    @feature = f
  end

  def to_es_bulk_operation
    [ { index: { _index:ContentBase.es_index, _type:self.obj_class.underscore, _id:self.id } }, self.to_hash ]
  end

  def to_hash
    {
      obj_key:          @id,
      title:            @title,
      short_title:      @short_title,
      public_datetime:  @public_datetime,
      teaser:           @teaser,
      body:             @body,
      category:         @category,
      byline:           @byline,
      attributions:     @attributions,
      feature:          @feature,
      tags:             @tags,
      assets:           @assets,
      audio:            @audio,
      published:        @published,
      created_at:       @created_at,
      updated_at:       @updated_at,
      edit_path:        @edit_path,
      public_path:      @public_path,
      blog:             @blog,
      show:             @show,
      related_content:  related_content,
      links:            links,
      asset_display:    asset_display,
      disqus_identifier: disqus_identifier,
      abstract:         abstract,
      from_pij:         from_pij?
    }
  end

  alias_method :to_h, :to_hash

  def to_reference
    Hashie::Mash.new({
      id:           @id,
      public_path:  @public_path,
      title:        @title,
      short_title:  @short_title,
      category:     @category,
      feature: Hashie::Mash.new({name: (feature.try(:name) || "Article"), _key: (feature.try(:key) || "article")}),
      has_audio?:  (@audio || []).any?,
      has_assets?: (@assets || []).any?,
      has_links?:  (@links || []).any?,
      disqus_identifier: @disqus_identifier
    })
  end

  #----------

  def ==(comp)
    comp.class == self.class && comp.id == self.id
  end

  # This only needs to be done on initial switchover or on a new environment
  def self._index_all_articles
    # make sure our mapping templates are current
    self._put_article_mapping

    # -- Index Articles -- #

    klasses = ["NewsStory","BlogEntry","ShowSegment","ShowEpisode","ContentShell","Event","PijQuery","Abstract"]

    klasses.each do |k|
      k.constantize.with_article_includes.find_in_batches(batch_size:1000) do |b|
        ES_CLIENT.bulk body:b.collect { |s| s.to_article.try(:to_es_bulk_operation) }.compact().flatten(1)
      end
    end
  end

  #----------

  def self._put_article_mapping
    # -- Put our settings and mapping -- #

    ContentBase.es_client.indices.put_template name:"#{ES_PREFIX}-settings", body:{
      template:"#{ES_PREFIX}-*",
      settings:{
        'index.number_of_shards'    => 5,
        'index.number_of_replicas'  => 1
      },
    }

    mapping = JSON.parse(File.read("#{Rails.root}/config/article_mapping.json"))
    ContentBase.es_client.indices.put_template name:"#{ES_PREFIX}-articles", body:{template:"#{ES_PREFIX}-articles-*",mappings:mapping}
  end

end
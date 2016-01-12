class PmpStory < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'story'")}
  has_many :pmp_audio, dependent: :destroy, foreign_key: :pmp_content_id, class_name: :PmpAudio
  has_many :pmp_images, dependent: :destroy, foreign_key: :pmp_content_id

  def publish
    if content
      doc = build_doc
      if doc.save
        update! guid: doc.guid
      end
    else
      raise ActiveRecord::RecordNotFound
    end      
  end

  def build_doc
    doc = pmp('write').doc_of_type(profile)
    doc.parse_attributes({
      title:            content.headline,
      teaser:           content.teaser,
      byline:           content.byline,
      tags:             content.tags.map(&:slug),
      published:        content.published_at,
      guid:             guid,
      description:      Nokogiri::HTML(content.body).xpath("//text()").css('body').to_s,
      contentencoded:   ApplicationHelper.render_with_inline_assets(content), # this sucks
      contenttemplated: content.body,
    })
    doc.links['permissions'] = permissions
    doc.links['alternate']   = content.url
    doc.links['copyright'] = PMP::Link.new({href: "http://www.scpr.org/terms/"})

    doc.links['item'] ||= []

    if content.respond_to?(:audio)
      doc.links['item'].concat(content.audio.map do |a|
        audio_content = pmp_audio.first_or_create(content: a)
        audio_content.publish unless audio_content.published?
        audio_content.link
      end.compact)
    end

    if content.respond_to?(:assets)
      doc.links['item'].concat(content.assets.map do |i|
        if i.owner.include?("KPCC")
          image_content = pmp_images.first_or_create(content: i)
          image_content.publish unless image_content.published?
          image_content.link
        end
      end.compact)
    end

    doc
  end

  def set_profile
    self.profile ||= "story"
  end

end
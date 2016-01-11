class PmpStory < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'story'")}
  has_many :pmp_audios, dependent: :destroy
  has_many :pmp_images, dependent: :destroy

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
    doc = pmp.doc_of_type(profile)
    doc.parse_attributes({
      title:            content.headline,
      teaser:           content.teaser,
      byline:           content.byline,
      tags:             content.tags.map(&:slug),
      published:        content.published_at,
      guid:             guid,
      description:      content.body,
      contentencoded:   content.body,
      contenttemplated: content.body,
    })
    doc.links['permissions'] = permissions
    doc.links['alternate']   = content.url
    doc.links['copyright'] = PMP::Link.new({href: "http://www.scpr.org/terms/"})

    doc.links['item'] ||= []

    if content.respond_to?(:audio)
      doc.links['item'].concat(content.audio.map do |a|
        audio_content = a.parent || PmpAudio.create(content: a, pmp_story: self, profile: "audio")
        audio_content.publish unless audio_content.published?
        audio_content.link
      end.compact)
    end

    if content.respond_to?(:assets)
      doc.links['item'].concat(content.assets.map do |i|
        image_content = i.parent || PmpImage.create(content: i, pmp_story: self, profile: "image")
        image_content.publish unless image_content.published?
        image_content.link
      end.compact)
    end

    doc
  end

  def set_profile
    self.profile ||= "story"
  end

end
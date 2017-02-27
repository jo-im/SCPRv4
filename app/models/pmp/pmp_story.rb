class PmpStory < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'story'")}
  has_many :pmp_audio, dependent: :destroy, foreign_key: :pmp_content_id, class_name: :PmpAudio
  has_many :pmp_images, dependent: :destroy, foreign_key: :pmp_content_id
  has_many :pmp_broadcast, dependent: :destroy, foreign_key: :pmp_content_id, class_name: :PmpBroadcast

  def publish
    doc = build_docs
    if doc.save
      update! guid: doc.guid
    end
  end

  def build_doc
    doc = pmp('write').doc_of_type(profile)
    doc.parse_attributes({
      title:            content.headline,
      teaser:           content.teaser,
      byline:           content.byline,
      tags:             content.try(:tags).try(:map, &:pmp_alias) || [],
      published:        content.try(:published_at) || content.updated_at,
      guid:             guid,
      description:      content.plaintext_body,
      contentencoded:   content.rendered_body,
      contenttemplated: content.templated_body,
    })
    doc.links['permissions'] = permissions
    doc.links['alternate']   = content.public_url
    doc.links['copyright'] = PMP::Link.new({href: "http://www.scpr.org/terms/"})

    doc.links['item'] ||= []

    doc
  end

  ## This will publish audio and image docs.  You have been warned.
  def build_docs
    doc = build_doc
    if content.respond_to?(:audio)
      doc.links['item'].concat(content.audio.map do |a|
        audio_content = pmp_audio.where(content: a).first_or_create
        audio_content.publish unless audio_content.published?
        audio_content.link
      end.compact)
    end
    if content.respond_to?(:assets)
      doc.links['item'].concat(content.assets.map do |i|
        if i.owner.try(:include?, "KPCC")
          image_content = pmp_images.where(content: i).first_or_create
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
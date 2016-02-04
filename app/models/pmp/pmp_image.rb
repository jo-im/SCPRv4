class PmpImage < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'image'")}
  belongs_to :pmp_story, class_name: :PmpStory, foreign_key: :pmp_content_id
  belongs_to :pmp_episode, class_name: :PmpEpisode, foreign_key: :pmp_content_id
  belongs_to :content, polymorphic: true

  validate :belongs_to_kpcc?

  def publish
    if belongs_to_kpcc?
      doc = build_doc
      if url = doc.save
        update! guid: doc.guid
      end
    else
      false
    end
  end

  def build_doc
    i = content
    doc = pmp('write').doc_of_type("image")
    doc.title = i.caption
    doc.byline = i.owner
    doc.links ||= {}
    doc.links['enclosure'] = ([:primary, :large, :medium, :square].map do |size|
      img = i.send(size)
      PMP::Link.new({
        href: img.url,
        title: i.caption,
        meta: {
          width: img.width,
          height: img.height
        },
        type: "image/jpeg"
      })
    end.compact)
    doc.links['copyright'] = PMP::Link.new({href: "http://www.scpr.org/terms/"})
    doc
  end

  def set_profile
    self.profile ||= "image"
  end

  def belongs_to_kpcc?
    (content && content.owner.try(:include?, "KPCC")) ? true : false
  end

end
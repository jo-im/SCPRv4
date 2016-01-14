class PmpImage < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'image'")}
  belongs_to :pmp_story, class_name: :PmpStory, foreign_key: :pmp_content_id
  belongs_to :pmp_episode, class_name: :PmpEpisode, foreign_key: :pmp_content_id
  belongs_to :content, polymorphic: true

  def publish
    if i = content
      idoc = pmp('write').doc_of_type("image")
      idoc.title = i.caption
      idoc.byline = i.owner
      idoc.links ||= {}
      idoc.links['enclosure'] = ([:primary, :large, :medium, :square].map do |size|
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
      idoc.links['copyright'] = PMP::Link.new({href: "http://www.scpr.org/terms/"})
      if url = idoc.save
        update! guid: idoc.guid
      end
    else
      false
    end
  end

  def set_profile
    self.profile ||= "image"
  end  

end
class PmpAudio < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'audio'")}
  belongs_to :pmp_story, class_name: :PmpStory, foreign_key: :pmp_content_id

  def publish
    if a = content
      adoc = pmp('write').doc_of_type("audio")
      adoc.title = a.description
      adoc.links ||= {}
      adoc.links['enclosure'] ||= []
      adoc.links['enclosure'] << PMP::Link.new({
        href: a.url,
        title: a.description,
        type: "audio/mpeg"
      })
      adoc.links['copyright'] = PMP::Link.new({href: "http://www.scpr.org/terms/"})
      if url = adoc.save
        update! guid: adoc.guid
      end
    else
      false
    end
  end

  def set_profile
    self.profile ||= "audio"
  end
end
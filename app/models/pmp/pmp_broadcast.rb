class PmpBroadcast < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'broadcast'")}
  belongs_to :pmp_story, class_name: :PmpStory, foreign_key: :pmp_content_id
  belongs_to :pmp_episode, class_name: :PmpEpisode, foreign_key: :pmp_content_id

  def publish
    if b = content
      # Remember to change the below line to use
      # the broadcast profile once it has been created.
      # The audio profile will suffice for now.
      bdoc         = pmp('write').doc_of_type("audio")
      # Since we are using a custom profile, we inject it here.
      bdoc.profile = PMP::Link.new({
        href: "#{PMPCONFIG['endpoint']}docs/#{PMPCONFIG['profiles']['broadcast']['guid']}"
      })
      bdoc.title   = b.headline
      bdoc.script  = b.body
      bdoc.links ||= {}
      bdoc.links['enclosure'] ||= []
      b.audio.each do |a|
        bdoc.links['enclosure'] << PMP::Link.new({
          href: a.url,
          title: b.headline,
          type: "audio/mpeg"
        })
      end
      bdoc.links['copyright'] = PMP::Link.new({href: "http://www.scpr.org/terms/"})
      if url = bdoc.save
        update! guid: bdoc.guid
      end
    else
      false
    end
  end

  def set_profile
    self.profile ||= "broadcast"
  end
end
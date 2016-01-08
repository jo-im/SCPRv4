class PmpContent < ActiveRecord::Base

  belongs_to :content, polymorphic: true, required: true
  ## figure out why the api won't let us delete, then we can enable these
  belongs_to :pmp_content
  has_many :pmp_contents, dependent: :destroy
  # before_destroy :destroy_from_pmp
  scope :story, ->{where(profile: "story")}
  scope :audio, ->{where(profile: "audio")}
  scope :image, ->{where(profile: "image")}
  scope :published, ->{where.not(guid: nil)}
  scope :unpublished, ->{where(guid: nil)}

  def published?
    guid ? true : false
  end

  def href
    if guid
      "https://api-sandbox.pmp.io/docs/#{guid}"
    else
      nil
    end
  end

  def publish
    if profile
      send "publish_#{profile}"
    else
      false
    end
  end

  def publish_story
    if content
      doc = build_docs
      if doc.save
        update! guid: doc.guid
      end
    else
      raise ActiveRecord::RecordNotFound
    end      
  end

  def publish_audio
    if a = content
      adoc = pmp.doc_of_type("audio")
      adoc.title = a.description
      adoc.links ||= {}
      adoc.links['enclosure'] ||= []
      adoc.links['enclosure'] << PMP::Link.new({
        href: a.url,
        title: a.description,
        type: "audio/mpeg"
      })
      if url = adoc.save
        update! guid: adoc.guid
      end
    else
      false
    end
  end

  def publish_image
    if a = content
      adoc = pmp.doc_of_type("image")
      adoc.title = a.caption
      adoc.byline = a.owner
      adoc.links ||= {}
      adoc.links['enclosure'] = ([:primary, :large, :medium, :square].map do |size|
        img = a.send(size)
        PMP::Link.new({
          href: img.url,
          title: a.caption,
          meta: {
            width: img.width,
            height: img.height
          },
          type: "image/jpeg"
        })
      end.compact)
      ## TODO
      # adoc.links['copyright'] = ...
      if url = adoc.save
        update! guid: adoc.guid
      end
    else
      false
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
    doc
  end

  def build_docs
    doc = build_doc
    doc.links['item'] ||= []

    if content.respond_to?(:audio)
      doc.links['item'].concat(content.audio.map do |a|
        audio_content = a.pmp_content || self.class.create(content: a, pmp_content: self, profile: "audio")
        audio_content.publish unless audio_content.published?
        audio_content.href ? PMP::Link.new(href: audio_content.href) : nil
      end.compact)
    end

    if content.respond_to?(:assets)
      doc.links['item'].concat(content.assets.map do |i|
        image_content = i.pmp_content || self.class.create(content: i, pmp_content: self, profile: "image")
        image_content.publish unless image_content.published?
        image_content.href ? PMP::Link.new(href: image_content.href) : nil
      end.compact)
    end

    doc
  end

  def destroy_from_pmp
    if guid
      ## Maybe we have to actually fetch it and that's why it doesn't actually delete?
      doc = pmp.doc_of_type(profile)
      doc.guid = guid
      doc.delete
      true
    else
      false
    end
  end

  def retrieve
    if guid
      ref = pmp.root.query['urn:collectiondoc:query:docs'].where(guid: guid).retrieve
      ref.retrieve # why do we need to do this twice?
      ref
    else
      nil
    end
  end

  def pmp
    config = Rails.configuration.x.api.pmp.sandbox

    client = PMP::Client.new({
      :client_id        => config['client_id'],
      :client_secret    => config['client_secret'],
      :endpoint         => "https://api-sandbox.pmp.io/"
    })

    # Load the root document
    client.root.load
    client
  end

end
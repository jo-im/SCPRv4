class PmpContent < ActiveRecord::Base

  belongs_to :content, polymorphic: true, required: true
  belongs_to :parent, class_name: :PmpContent, foreign_key: :pmp_content_id
  has_many :children, foreign_key: :pmp_content_id, class_name: :PmpContent
  after_initialize :set_profile
  ## figure out why the api won't let us delete, then we can enable this
  before_destroy :destroy_from_pmppubli
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

  def build_doc
    doc = pmp.doc_of_type(profile)
    doc.parse_attributes({
      title:            content.headline,
      teaser:           content.teaser,
      byline:           content.byline,
      tags:             content.tags.map(&:slug),
      published:        content.published_at,
      guid:             guid,
      description:      Nokogiri::HTML(content.body).xpath("//text()").to_s,
      # contentencoded:   ApplicationHelper.render_with_inline_assets(content.body), # wow, this sucks
      contentencoded:   content.body,
      contenttemplated: content.body,
    })
    doc.links['permissions'] = permissions
    doc
  end

  def destroy_from_pmp
    if guid
      ## Maybe we have to actually fetch it and that's why it doesn't actually delete?
      # doc = pmp.doc_of_type(profile)
      # pmp.root.query['urn:collectiondoc:query:docs']
      # .where(guid: guid, limit: 1).items.each do |doc|
      #   doc.delete
      # end
      doc = pimp.query['urn:collectiondoc:hreftpl:docs'].where(guid: guid)
      doc.destroy
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

  class << self
    def pmp action="read"
      config = Rails.configuration.x.api.pmp

      client = PMP::Client.new({
        :client_id        => config[action]['client_id'],
        :client_secret    => config[action]['client_secret'],
        :endpoint         => config[action]['endpoint']
      })

      # Load the root document
      client.root.load
      client
    end
  end

  def pmp
    self.class.pmp
  end

  def link
    href && PMP::Link.new(href: href)
  end

  def permissions
    groups = content.pmp_permission_groups
    groups.concat(parent.permissions) if parent # inherit permissions from parent document
    groups
  end

  private

  def set_profile
    nil
  end

end
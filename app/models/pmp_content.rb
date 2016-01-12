class PmpContent < ActiveRecord::Base

  belongs_to :content, polymorphic: true, required: true
  belongs_to :parent, class_name: :PmpContent, foreign_key: :pmp_content_id
  has_many :children, foreign_key: :pmp_content_id, class_name: :PmpContent
  after_initialize :set_profile
  ## figure out why the api won't let us delete, then we can enable this
  before_destroy :destroy_from_pmp
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

  def destroy_from_pmp
    if guid && doc = retrieve('write')
      delete_response = doc.delete
      if delete_response && delete_response.raw.status == 204
        self.update guid: nil
        true
      else
        false
      end
    else
      false
    end
  end

  def retrieve action="read"
    if guid
      ref = pmp(action).query['urn:collectiondoc:hreftpl:docs'].where(guid: guid).retrieve
      ref.retrieve
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

      client.root.retrieve
      client
    end
  end

  def pmp *args
    self.class.pmp(*args)
  end

  def link
    href && PMP::Link.new(href: href)
  end

  def permissions
    groups = content.pmp_permission_groups
    groups.concat(parent.permissions) if parent # inherit permissions from parent document
    groups
  end

  def async_publish
    Resque.enqueue(Job::PublishPmpContent, profile, id)
  end

  private

  def set_profile
    nil
  end

end
class PmpContent < ActiveRecord::Base

  belongs_to :content, polymorphic: true
  belongs_to :parent, class_name: :PmpContent, foreign_key: :pmp_content_id
  has_many :children, foreign_key: :pmp_content_id, class_name: :PmpContent
  after_initialize :set_profile
  before_destroy :destroy_from_pmp
  scope :published, ->{where.not(guid: nil)}
  scope :unpublished, ->{where(guid: nil)}

  PMPCONFIG = Rails.configuration.x.api.pmp

  ## This model should act like an abstract class, even though I didn't
  ## syntactically write it as an abstract class.  PMP models that represent
  ## a profile should inherit from this class and each have their own #publish
  ## method which constructs their doc and saves the doc to the PMP.

  def published?
    guid ? true : false
  end

  def href
    if guid
      "#{PMPCONFIG['endpoint']}docs/#{guid}"
    else
      nil
    end
  end

  def destroy_from_pmp
    if guid && doc = retrieve('write')
      delete_response = doc.delete
      if delete_response && delete_response.raw.status == 204
        self.update guid: nil
      end
    end
  rescue RuntimeError => err
    NewRelic.log_error(err)
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
      PMP::Client.new({
        :client_id        => PMPCONFIG[action]['client_id'],
        :client_secret    => PMPCONFIG[action]['client_secret'],
        :endpoint         => PMPCONFIG['endpoint']
      })
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
class RelatedLink < ActiveRecord::Base
  include Concern::Sanitizers::Url

  before_validation ->{ sanitize_urls :url }

  TYPES = [
    ["Website", "website"],
    ["Related Story", "related"],
    ["PIJ Query", "query"],
    ["Video (youtube, vimeo...)", "video"],
    ["Facebook", "facebook"],
    ["Twitter Handle (without @)", "twitter"],
    ["Document (pdf, doc, xls...)", "doc"],
    ["RSS Feed (xml)", "rss"],
    ["Podcast Feed (xml)", "podcast"],
    ["Map", "map"],
    ["Email (mailto:scprweb@scpr.org)", "email"],
    ["Other", "other"]
  ]

  #--------------
  # Scopes
  scope :query, -> { where(link_type: "query") }
  scope :normal, -> { where("link_type != ?", "query") }

  #--------------
  # Association
  belongs_to :content, polymorphic: true

  #--------------
  # Validation
  validates :title, presence: true
  validates :url,
    :presence   => true,
    :unless         => :is_twitter?,
    :url        => { allowed: [URI::HTTP, URI::FTP, URI::MailTo] }

  #--------------
  # Callbacks

  #----------
  # TODO Move this into a presenter
  def domain
    @domain ||= begin
      if self.url
        URI.parse(URI.encode(self.url)).host
      end
    end
  end

  def is_twitter?
    link_type == "twitter"
  end

  def to_hash
    {
      title: title,
      url: url,
      link_type: link_type
    }
  end
end

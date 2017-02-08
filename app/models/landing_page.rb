class LandingPage < ActiveRecord::Base
  outpost_model
  has_secretary

  self.public_route_key = "root_slug"

  has_many :landing_page_reporters, dependent: :destroy
  has_many :reporters,
    :through => :landing_page_reporters,
    :source  => :bio
  tracks_association :reporters

  has_many :landing_page_contents,
    -> { order('position') },
    :class_name => "LandingPageContent",
    :dependent  => :destroy

  accepts_json_input_for :landing_page_contents
  tracks_association :landing_page_contents

  validates :title, :slug, presence: true

  def featured_contents
    @featured_contents ||= self.landing_page_contents
  end

  def route_hash
    return {} if !self.persisted?
    { path: self.persisted_record.slug }
  end

  private

  def build_landing_page_content_association(landing_page_content_hash, article)
    LandingPageContent.new(
      :position   => landing_page_content_hash["position"].to_i,
      :article    => article,
      :landing_page   => self
    )
  end
end

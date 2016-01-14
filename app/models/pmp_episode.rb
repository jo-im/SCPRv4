class PmpEpisode < PmpStory

  has_many :pmp_stories, dependent: :destroy, foreign_key: :pmp_content_id

  def build_doc
    doc = super
    if content.respond_to?(:segments)
      doc.links['item'].concat(content.segments.map do |seg|
        segment_content = pmp_stories.where(content: seg).first_or_create
        segment_content.publish unless segment_content.published?
        segment_content.link
      end.compact)
    end
    doc
  end

  def set_profile
    self.profile ||= "episode"
  end

  def self.default_scope
    where("pmp_contents.profile = 'episode'")
  end

end
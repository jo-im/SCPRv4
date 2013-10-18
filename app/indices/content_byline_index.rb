ThinkingSphinx::Index.define :content_byline, with: :active_record do
  indexes user.name, as: :name
  has role
  has user_id
  has content_id

  has content(:published_at),
    :type   => :timestamp,
    :as     => :published_at

  has content(:status),
    :type   => :integer,
    :as     => :status

  polymorphs content,
    to: %w(BlogEntry ContentShell NewsStory ShowSegment)
end

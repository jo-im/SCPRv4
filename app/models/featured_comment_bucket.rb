class FeaturedCommentBucket < ActiveRecord::Base
  self.table_name = 'contentbase_featuredcommentbucket'
  outpost_model
  has_secretary

  has_many :comments,
    -> { order("created_at desc") },
    :class_name     => "FeaturedComment",
    :foreign_key    => "bucket_id"

  validates :title, presence: true

  class << self
    def select_collection
      FeaturedCommentBucket.order("title").map { |b| [b.title, b.id] }
    end
  end
end

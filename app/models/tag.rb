class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true

  has_many :taggings, dependent: :destroy

  def taggables(options={})
    ContentBase.search({ with: { "tags.slug" => self.slug } }.reverse_merge(options))
  end

  def articles(options={})
    taggables(options)
  end

  def update_timestamps
    update began_at: earliest_published_at, most_recent_at: latest_published_at
  end

  private

  def taggable_classes
    ActiveRecord::Base.connection.execute(
      "
        SELECT taggable_type FROM taggings
        WHERE tag_id = #{id}
        GROUP BY taggable_type
      "
    )
      .to_a
      .map{|r| ActiveRecord::Base.const_get(r[0]) rescue nil}
      .compact
  end

  def unsorted_published_at_dates_query
    ## Constructs an SQL query string to gather an array of all published_at dates from content associated with the tag.
    taggable_classes.map { |m|
      "SELECT #{m.table_name}.published_at FROM #{m.table_name}
      INNER JOIN taggings
      ON taggable_type = '#{m.to_s}' AND taggings.tag_id = #{id}
      "
    }.join("\nUNION\n")
  end

  def published_at_dates order="ASC", limit=1
    missing_date = Class.new do
      def first
        nil
      end
    end
    limit_statement = "LIMIT #{limit}"
    row = ActiveRecord::Base.connection.execute(
      "SELECT * FROM
      (
        #{unsorted_published_at_dates_query}
      ) AS unsorted_dates
      WHERE published_at IS NOT NULL
      ORDER BY published_at #{order}
      #{limit_statement if limit}
      "
      )
    (row.to_a.first || missing_date.new).first
  end

  def earliest_published_at
    published_at_dates "ASC", 1
  end

  def latest_published_at
    published_at_dates "DESC", 1
  end
end

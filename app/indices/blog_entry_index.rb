ThinkingSphinx::Index.define :blog_entry, with: :active_record do
  indexes headline
  indexes body
  indexes bylines.user.name, as: :bylines

  has blog.id, as: :blog
  has status
  has published_at
  has updated_at

  has "CRC32(CONCAT('#{BlogEntry.content_key}" \
      "#{Outpost::Model::Identifier::OBJ_KEY_SEPARATOR}'," \
      "#{BlogEntry.table_name}.id))",
    :type   => :integer,
    :as     => :obj_key

  # For RSS feeds
  has "1",
    :type   => :boolean,
    :as     => :is_source_kpcc

  # For the megamenu
  has category.is_news, as: :category_is_news

  # For the homepage/category sections
  has category.id, as: :category
  has asset_type_id

  # For podcasts
  join audio
  has "COUNT(DISTINCT #{Audio.table_name}.id) > 0",
    :type   => :boolean,
    :as     => :has_audio

  # Required attributes for ContentBase.search
  has published_at, as: :public_datetime
  has "#{BlogEntry.table_name}.status = #{ContentBase::STATUS_LIVE}",
    :type   => :boolean,
    :as     => :is_live
end

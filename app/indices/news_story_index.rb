ThinkingSphinx::Index.define :news_story, with: :active_record do
  indexes headline
  indexes body
  indexes bylines.user.name, as: :bylines

  has status
  has published_at
  has updated_at
  has "CRC32(CONCAT('#{NewsStory.content_key}" \
      "#{Outpost::Model::Identifier::OBJ_KEY_SEPARATOR}'," \
      "#{NewsStory.table_name}.id))",
    :type   => :integer,
    :as     => :obj_key

  # For megamenu
  has category.is_news, as: :category_is_news

  # For category/homepage building
  has category.id, as: :category
  has asset_display_id

  # For RSS Feed
  has "(#{NewsStory.table_name}.source <=> 'kpcc')",
    :type   => :boolean,
    :as     => :is_source_kpcc

  # For podcasts
  join audio
  has "COUNT(DISTINCT #{Audio.table_name}.id) > 0",
    :type   => :boolean,
    :as     => :has_audio

  # Required attributes for ContentBase.search
  has published_at, as: :public_datetime
  has "#{NewsStory.table_name}.status = #{ContentBase::STATUS_LIVE}",
    :type   => :boolean,
    :as     => :is_live
end

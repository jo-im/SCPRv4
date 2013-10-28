ThinkingSphinx::Index.define :show_segment, with: :active_record do
  indexes headline
  indexes teaser
  indexes body
  indexes bylines.user.name, as: :bylines

  has show.id, as: :program
  has status
  has published_at
  has updated_at
  has "CRC32(CONCAT('#{ShowSegment.content_key}" \
      "#{Outpost::Model::Identifier::OBJ_KEY_SEPARATOR}'," \
      "#{ShowSegment.table_name}.id))",
    :type   => :integer,
    :as     => :obj_key

  # For the megamenu
  has category.is_news, as: :category_is_news

  # For category/homepage sections
  has category.id, as: :category
  has "(#{ShowSegment.table_name}.segment_asset_scheme <=> 'slideshow')",
    :type   => :boolean,
    :as     => :is_slideshow

  # For RSS Feed
  has "1",
    :type   => :boolean,
    :as     => :is_source_kpcc

  # For podcast searches
  join audio
  has "COUNT(DISTINCT #{Audio.table_name}.id) > 0",
    :type   => :boolean,
    :as     => :has_audio

  # Required attributes for ContentBase.search
  has published_at, as: :public_datetime
  has "#{ShowSegment.table_name}.status = #{ContentBase::STATUS_LIVE}",
    :type   => :boolean,
    :as     => :is_live
end

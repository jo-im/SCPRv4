ThinkingSphinx::Index.define :content_shell, with: :active_record do
  indexes headline
  indexes body
  indexes bylines.user.name, as: :bylines

  has status
  has published_at
  has updated_at
  has "CRC32(CONCAT('#{ContentShell.content_key}" \
      "#{Outpost::Model::Identifier::OBJ_KEY_SEPARATOR}'," \
      "#{ContentShell.table_name}.id))",
    :type   => :integer,
    :as     => :obj_key

  # For category/homepage building
  has category.id, as: :category
  has tags.slug, as: :tags

  # For Feeds - we only want to send our original content to RSS
  # (not stuff copies from AP or NPR, for example)
  has "1",
    :type   => :boolean,
    :as     => :is_source_kpcc

  # Required attributes for ContentBase.search
  has published_at, as: :public_datetime
  has "#{ContentShell.table_name}.status = #{ContentShell.status_id(:live)}",
    :type   => :boolean,
    :as     => :is_live
end

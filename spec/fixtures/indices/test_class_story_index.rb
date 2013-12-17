ThinkingSphinx::Index.define 'test_class/story', with: :active_record do
  indexes headline
  indexes body

  has status
  has published_at
  has updated_at

  has "CRC32(CONCAT('#{TestClass::Story.content_key}" \
      "#{Outpost::Model::Identifier::OBJ_KEY_SEPARATOR}'," \
      "#{TestClass::Story.table_name}.id))",
    :type   => :integer,
    :as     => :obj_key

  # Required attributes for ContentBase.search
  has published_at, as: :public_datetime
  has "#{TestClass::Story.table_name}.status = #{TestClass::Story.status_id(:live)}",
    :type   => :boolean,
    :as     => :is_live
end

ThinkingSphinx::Index.define :pij_query, with: :active_record do
  indexes headline
  indexes body
  indexes teaser
  indexes pin_query_id
  has published_at
  has status

  # Required attributes for ContentBase.search
  has published_at, as: :public_datetime
  has "#{PijQuery.table_name}.status = #{PijQuery.status_id(:live)}",
    :type   => :boolean,
    :as     => :is_live
end

ThinkingSphinx::Index.define :event, with: :active_record do
  indexes headline
  indexes body
  indexes sponsor
  indexes location_name
  indexes city

  has starts_at
  has status

  # Required attributes for ContentBase.search
  has created_at, as: :public_datetime
  has "#{Event.table_name}.status = #{Event::STATUS_LIVE}",
    :type   => :boolean,
    :as     => :is_live
end

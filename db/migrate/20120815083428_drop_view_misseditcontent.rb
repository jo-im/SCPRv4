class DropViewMisseditcontent < ActiveRecord::Migration
  def up
    execute("drop view rails_contentbase_misseditcontent")
  end
  
  def down
    execute("
      create or replace
      SQL SECURITY INVOKER
      view rails_contentbase_misseditcontent as 
      select 
        l.id,
        l.bucket_id,
        l.object_id as content_id,
        m.class_name as content_type,
        l.position
      from 
        contentbase_misseditcontent as l, 
        rails_content_map as m 
      where l.content_type_id = m.id
    ")
  end
end

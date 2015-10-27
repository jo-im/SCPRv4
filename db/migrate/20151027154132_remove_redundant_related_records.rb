class RemoveRedundantRelatedRecords < ActiveRecord::Migration
  def up
    r = Related.all
    pairs = {}
    r.each do |obj|
      key = [[obj.content_type,obj.content_id].join("_"),[obj.related_type,obj.related_id].join("_")].sort().join("-")
      (pairs[key] ||= []).push obj
    end
    pairs.each do |k,objs|
      obj, *bad_objs = objs
      bad_objs.each(&:destroy)
      if obj.content_id == obj.related_id && obj.content_type == obj.related_type
        obj.destroy 
      end
    end
  end
  def down
  end
end

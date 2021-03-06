class Outpost::FeaturedCommentsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "created_at"
    l.default_order_direction   = DESCENDING

    l.column :bucket
    l.column :content
    l.column :username
    l.column :excerpt
    l.column :status
    l.column :created_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :bucket_id,
      :collection => -> { FeaturedCommentBucket.select_collection }

    l.filter :status,
      :collection => -> { FeaturedComment.status_select_collection }
  end
end

class Outpost::NewsStoriesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :byline
    l.column :audio
    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status, display: :display_article_status
    l.column :updated_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :published_to_pmp?, display: :display_pmp_status

    l.filter :status, collection: -> { NewsStory.status_select_collection }
    l.filter :bylines, collection: -> { Bio.select_collection }
    l.filter :source, collection: -> { NewsStory.source_select_collection }
  end

  #----------------

  def preview
    @entry = Outpost.obj_by_key(params[:obj_key]) || NewsStory.new

    with_rollback @entry do

      @entry.assign_attributes(unescape_params(params[:news_story]))

      if @entry.unconditionally_valid?
        @entry.update_inline_assets
        @title = @entry.to_title
        render "shared/new/_single_preview",
          :layout => "application",
          :locals => {
            :story => @entry
          }
      else
        render_preview_validation_errors(@entry)
      end
    end
  end

  private

  def unescape_params params
    # Takes params values that are interpreted as binary and convert them to UTF-8.
    params.transform_values { |v|
      if v.respond_to?(:encoding) && v.encoding.to_s.include?("ASCII-8BIT")
        begin
          CGI.unescape v
        rescue
          if v.respond_to? :encode
            v.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
          else
            v
          end
        end
      else
        v
      end
    }
  end

end

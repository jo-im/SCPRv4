class Outpost::FlatpagesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "path"
    l.default_order_direction   = ASCENDING

    l.column :title
    l.column :path,
      :sortable                   => true,
      :default_order_direction    => ASCENDING

    l.column :redirect_to
    l.column :updated_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :is_public, header: "Public?"

    l.filter :is_public,
      :title        => "Public?",
      :collection   => :boolean
  end

  #------------------

  def preview
    @flatpage = Outpost.obj_by_key(params[:obj_key]) || Flatpage.new

    with_rollback @flatpage do
      @flatpage.assign_attributes(params[:flatpage])

      if @flatpage.unconditionally_valid?
        @title = @flatpage.to_title

        if @flatpage.is_redirect?
          render 'outpost/shared/_notice',
            :layout => "outpost/minimal",
            :locals => {
              :message => "This flatpage will redirect to " \
                          "<strong>#{@flatpage.redirect_to}</strong>".html_safe
              }
        else
          render "flatpages/_flatpage",
            :layout => "outpost/preview/new/application",
            :locals => { flatpage: @flatpage }
        end
      else
        render_preview_validation_errors(@flatpage)
      end
    end
  end

  private

  def flatpage_layout_template
    template = FlatpageHandler::FLATPAGE_TEMPLATE_MAP[@flatpage.template]
    template = "application" if template.nil?
    template ? "outpost/preview/#{template}" : false
  end
end

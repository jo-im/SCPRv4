class Admin::EventsController < Admin::ResourceController
  def preview
    @event = ContentBase.obj_by_key(params[:obj_key])
    
    with_rollback @event do
      @event.assign_attributes(params[:event])
      @title = @event.to_title
      render "/events/_event", layout: "/admin/preview/application", locals: { event: @event }
    end
  end
end

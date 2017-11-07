class Outpost::EventsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "starts_at"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :starts_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :location_name, header: "Location"
    l.column :event_type,
      :header     => "Type",
      :display    => ->(r) { Event::EVENT_TYPES[r.event_type] }

    l.column :is_kpcc_event, header: "KPCC?"
    l.column :status

    l.column :published_to_pmp?, display: :display_pmp_status

    l.filter :is_kpcc_event,
      :title        => "KPCC Event?",
      :collection   => :boolean

    l.filter :event_type,
      :title        => "Type",
      :collection   => -> { Event.event_types_select_collection }

    l.filter :status,
      :title        => "Status",
      :collection   => -> { Event.status_select_collection }
  end

  #------------------

  def preview
    @event = Outpost.obj_by_key(params[:obj_key]) || Event.new
    @more_events = Event.kpcc_in_person.upcoming.where("id != ?", @event.id).limit(2)
    @past_events     = Event.kpcc_in_person.past.limit(5)
    @landing_page = LandingPage.find_by(title: 'KPCC In Person')

    with_rollback @event do
      @event.assign_attributes(params[:event])

      if @event.unconditionally_valid?
        @title = @event.to_title
        render "events/_event",
          :layout => "outpost/preview/application",
          :locals => {
            :event => @event
          }
      else
        render_preview_validation_errors(@event)
      end
    end
  end
end

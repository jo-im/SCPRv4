class Outpost::KpccProgramsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "title"
    l.default_order_direction   = ASCENDING

    l.column :title,
      :sortable                   => true,
      :default_order_direction    => ASCENDING

    l.column :air_status
    l.column :airtime
    l.column :host

    l.filter :air_status, collection: -> { KpccProgram::AIR_STATUS }
  end
end

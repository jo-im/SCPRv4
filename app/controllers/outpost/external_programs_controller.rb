class Outpost::ExternalProgramsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "title"
    l.default_order_direction   = ASCENDING

    l.column :title,
      :sortable                   => true,
      :default_order_direction    => ASCENDING

    l.column :airtime
    l.column :organization
    l.column :air_status

    l.filter :air_status, collection: -> { KpccProgram::AIR_STATUS }
  end
end

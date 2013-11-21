class Outpost::AdminUsersController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "name"
    l.default_order_direction   = "asc"

    l.column :username
    l.column :email
    l.column :name,
      :sortable                   => true,
      :default_order_direction    => "asc"

    l.column :is_superuser, header: "Superuser?"
    l.column :can_login, header: "Can Login?"

    l.filter :is_superuser, collection: :boolean
    l.filter :can_login, collection: :boolean
  end

  #---------------
  # Override this method from Outpost::ResourceController
  # Users should always be able to see and update their
  # own profile.
  def authorize_resource
    if %w{show edit update activity}.include?(action_name)
      get_record if !@record
      return true if @record == current_user
    end

    super
  end

  #---------------

  def activity
    get_record
    breadcrumb @record.to_title, @record.admin_edit_path, "Activity"
    list = Outpost::VersionsController.list

    @versions = @record.activities
      .order("#{list.default_order_attribute} #{list.default_order_direction}")
      .page(params[:page]).per(list.per_page)

    render '/outpost/versions/index', locals: { list: list }
  end
end

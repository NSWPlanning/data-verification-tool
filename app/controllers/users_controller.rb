class UsersController < AdminController

  # Setup breadcrumbs
  add_breadcrumb 'Users', '', :only => [:index]

  include ResourceController

  def admin
    @title = 'Admin Users'
    add_breadcrumb 'Administrators'
    @users = resource_scope.with_roles(:admin)
    render 'index'
  end

  protected
  def resource_scope
    User
  end

end

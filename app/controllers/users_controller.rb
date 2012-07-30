class UsersController < AdminController

  include ResourceController

  def admin
    @title = 'Admin Users'
    @users = resource_scope.with_roles(:admin)
    render 'index'
  end

  protected
  def resource_scope
    User
  end

end

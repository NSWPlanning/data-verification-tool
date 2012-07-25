class UsersController < AdminController

  respond_to :html

  def index
    @users = User.all
  end

  def show
    @user = find_user(params[:id])
    @title = @user.to_s
  end

  def new
    @title = 'Create new user'
    @user = User.new
    respond_with @user
  end

  def create
    @title = 'Create new user'
    @user = User.new
    @user.assign_attributes(params[:user], :as => current_role)
    @user.save
    respond_with @user
  end

  def edit
    @user = find_user(params[:id])
    @title = "Edit user #{@user}"
  end

  def update
    @user = find_user(params[:id])
    @user.assign_attributes(params[:user], :as => current_role)
    @user.save
    respond_with @user
  end

  protected
  def current_role
    current_user.admin? ? :admin : :default
  end

  protected
  def find_user(id)
    User.find(id)
  end

end

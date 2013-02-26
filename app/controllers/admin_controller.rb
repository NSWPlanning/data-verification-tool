class AdminController < AuthenticatedController

  before_filter :require_admin!

  def require_admin!
    render :nothing => true, :status => :forbidden unless current_user.admin?
  end

end

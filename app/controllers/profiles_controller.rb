class ProfilesController < AuthenticatedController

  respond_to :html

  def edit
    @title = 'Edit profile'
    @profile = current_user
    respond_with @user
  end

  def update
    @profile = current_user
    if @profile.update_attributes(params[:user])
      redirect_to root_url, :notice => 'Profile updated'
    else
      render 'edit'
    end
  end

end
